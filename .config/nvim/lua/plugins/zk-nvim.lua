-- Configuración del plugin zk-nvim y renderizado personalizado de citas Zk
-- En este archivo se maneja la integración con zk y la estética de las referencias {{citekey}}
return {
  "sanhuesoft/zk-nvim",
  name = "zk",
  opts = {
    picker = "fzf_lua",
    config = {
      hints = { enabled = false },
    },
    lsp = {
      config = {
        name = "zk",
        cmd = { "zk", "lsp" },
        filetypes = { "markdown" },
        on_attach = function(client, bufnr)
          -- Deshabilitar el resaltado de referencia del LSP para evitar conflictos con nuestros highlights
          client.server_capabilities.definitionProvider = false
        end,
      },
      auto_attach = {
        enabled = true,
      },
    },
  },
  config = function(_, opts)
    -- Inicializar zk-nvim con sus opciones
    require("zk").setup(opts)

    -- =========================================================================
    -- RESOLVEDOR DE TÍTULOS DE NOTAS CON CACHÉ
    -- =========================================================================
    local vault_path = "/Users/fabsanh/Mesh"
    local title_cache = {}

    local function get_note_title(note_id)
      if title_cache[note_id] then
        return title_cache[note_id]
      end

      local paths_to_try = {
        vault_path .. "/" .. note_id .. ".md",
        vault_path .. "/Journal/" .. note_id .. ".md",
        vault_path .. "/Bibliografía/" .. note_id .. ".md",
        vault_path .. "/Bibliografía/" .. note_id .. ".md",
      }

      local file_path = nil
      for _, path in ipairs(paths_to_try) do
        if vim.fn.filereadable(path) == 1 then
          file_path = path
          break
        end
      end

      if not file_path then
        local matches = vim.fn.globpath(vault_path, "**/" .. note_id .. ".md", true, true)
        if matches and #matches > 0 then
          file_path = matches[1]
        end
      end

      if file_path then
        local f = io.open(file_path, "r")
        if f then
          local title = nil
          local in_frontmatter = false
          for i = 1, 20 do
            local line = f:read("*line")
            if not line then
              break
            end

            local h1 = line:match("^#%s+(.+)$")
            if h1 then
              title = h1
              break
            end

            if line == "---" then
              in_frontmatter = not in_frontmatter
            elseif in_frontmatter then
              local yaml_title = line:match("^title:%s*[\"']?(.-)[\"']?$")
              if yaml_title then
                title = yaml_title
                break
              end
            end
          end
          f:close()

          if title then
            title_cache[note_id] = title
            return title
          end
        end
      end

      title_cache[note_id] = note_id
      return note_id
    end

    -- =========================================================================
    -- CONFIGURACIÓN DE HIGHLIGHTS Y FORMATO DE CITAS {{referencia}} Y WIKILINKS
    -- =========================================================================

    -- Grupo de highlight para la clave de la cita (citekey)
    -- Define color rosado, subrayado continuo y evita combinar con otros estilos
    local zk_hl = {
      fg = "#f38ba8",
      underline = true,
      undercurl = false,
      underdashed = false,
      underdotted = false,
      underdouble = false,
      nocombine = true,
    }
    vim.api.nvim_set_hl(0, "ZkCitation", zk_hl)

    -- Grupo de highlight para las citas en el menú de autocompletado (sin subrayado)
    local zk_menu_hl = {
      fg = "#f38ba8",
      underline = false,
      undercurl = false,
      underdashed = false,
      underdotted = false,
      underdouble = false,
      nocombine = true,
    }
    vim.api.nvim_set_hl(0, "ZkCitationMenu", zk_menu_hl)

    -- Grupo de highlight para los wikilinks renderizados (celeste)
    local wikilink_hl = {
      fg = "#89b4fa",
      underline = true,
      undercurl = false,
      underdashed = false,
      underdotted = false,
      underdouble = false,
      nocombine = true,
    }
    vim.api.nvim_set_hl(0, "ZkWikilink", wikilink_hl)

    -- Grupo de highlight para las llaves contenedoras {{ y }}
    -- Utiliza un color gris oscuro para atenuar o esconder visualmente las llaves
    vim.api.nvim_set_hl(0, "ZkCitationBrackets", { fg = "#585b70", nocombine = true })

    -- Escuchar cambios de tema (ColorScheme) para reinstaurar los highlights
    -- y evitar que nuevos temas pisen los colores específicos
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        vim.api.nvim_set_hl(0, "ZkCitation", zk_hl)
        vim.api.nvim_set_hl(0, "ZkCitationMenu", zk_menu_hl)
        vim.api.nvim_set_hl(0, "ZkWikilink", wikilink_hl)
        vim.api.nvim_set_hl(0, "ZkCitationBrackets", { fg = "#585b70", nocombine = true })
      end,
    })

    -- Escuchar cuando un cliente LSP se adjunta (LspAttach)
    -- Si el cliente es "zk", fuerza la redefinición para evitar
    -- que los tokens semánticos del servidor LSP anulen o apaguen el estilo
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "zk" then
          vim.api.nvim_set_hl(0, "ZkCitation", zk_hl)
          vim.api.nvim_set_hl(0, "ZkCitationMenu", zk_menu_hl)
          vim.api.nvim_set_hl(0, "ZkWikilink", wikilink_hl)
        end
      end,
    })

    -- Espacio de nombres exclusivo para las marcas virtuales (extmarks) de citas
    local namespace = vim.api.nvim_create_namespace("ZkCitations")
    local wikilinks_ns = vim.api.nvim_create_namespace("ZkWikilinks")

    -- Función que analiza el buffer y aplica decoraciones virtuales a los wikilinks
    local function highlight_wikilinks(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      if vim.bo[bufnr].filetype ~= "markdown" then
        return
      end

      -- Obtener la línea actual del cursor buscando la ventana que muestra este buffer
      local cursor_line = nil
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
          cursor_line = vim.api.nvim_win_get_cursor(win)[1] - 1
          break
        end
      end

      vim.api.nvim_buf_clear_namespace(bufnr, wikilinks_ns, 0, -1)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      for line_idx, line in ipairs(lines) do
        local start_idx = 1
        while true do
          local s, e, note_id = string.find(line, "%[%[([^|%]]+)%]%]", start_idx)
          if not s then
            break
          end

          local line_num = line_idx - 1
          local start_col = s - 1
          local end_col = e

          -- Si el cursor está en esta línea, no aplicamos ocultamiento ni texto virtual.
          -- Esto evita que el autocompletado y edición nativa choquen con el conceal del extmark.
          if not (cursor_line and line_num == cursor_line) then
            local title = get_note_title(note_id)
            vim.api.nvim_buf_set_extmark(bufnr, wikilinks_ns, line_num, start_col, {
              end_col = end_col,
              conceal = "",
              virt_text = { { "󰈔 " .. title, "ZkWikilink" } },
              virt_text_pos = "inline",
              hl_mode = "replace",
              priority = 201,
            })
          end

          start_idx = e + 1
        end
      end
    end

    -- Función que analiza el buffer y aplica decoraciones virtuales a las citas
    local function highlight_citations(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      -- Solo procesar archivos de tipo markdown
      if vim.bo[bufnr].filetype ~= "markdown" then
        return
      end

      -- Limpiar marcas virtuales previas dentro del namespace en todo el archivo
      vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      for line_idx, line in ipairs(lines) do
        local start_idx = 1
        while true do
          -- Buscar citas con formato especial (ej. {{Key:25-27}}, {{Peña2023}})
          local s, e, full = string.find(line, "{{([^%s{}]+)}}", start_idx)
          if not s then
            break -- No hay más citas en la línea actual
          end

          -- Extraer el citekey y el sufijo opcional de páginas separado por ':'
          local citekey = full:match("^([^:]+)")
          local pages_part = full:match(":(.+)$") -- nil si no hay especificación de páginas

          -- Calcular columnas (índice base 0) para posicionar las marcas
          local line_num = line_idx - 1
          local open_bracket_start = s - 1 -- Comienzo del '{{'
          local open_bracket_end = s + 1 -- Fin del '{{' (exclusivo)
          local citekey_end = open_bracket_end + #citekey -- Fin del citekey (exclusivo)
          local close_bracket_start = e - 2 -- Comienzo del '}}'
          local close_bracket_end = e -- Fin del '}}' (exclusivo)

          -- Llaves de apertura: Ocultar '{{' e inyectar un icono de libro inline (󰂺)
          vim.api.nvim_buf_set_extmark(bufnr, namespace, line_num, open_bracket_start, {
            end_col = open_bracket_end,
            hl_group = "ZkCitationBrackets",
            conceal = "",
            virt_text = { { "󰂺 ", "ZkCitation" } },
            virt_text_pos = "inline",
            hl_mode = "replace",
            priority = 200,
          })

          -- Clave de cita: Aplicar estilo visual de ZkCitation sin subrayar el icono de libro
          vim.api.nvim_buf_set_extmark(bufnr, namespace, line_num, open_bracket_end, {
            end_col = citekey_end,
            hl_group = "ZkCitation",
            hl_mode = "replace",
            priority = 200,
          })

          -- Números de página (si existen): Ocultar el sufijo ':páginas' de la vista normal
          if pages_part then
            vim.api.nvim_buf_set_extmark(bufnr, namespace, line_num, citekey_end, {
              end_col = close_bracket_start,
              hl_group = "ZkCitationBrackets",
              conceal = "",
              priority = 200,
            })
          end

          -- Llaves de cierre: Ocultar '}}' por completo
          vim.api.nvim_buf_set_extmark(bufnr, namespace, line_num, close_bracket_start, {
            end_col = close_bracket_end,
            hl_group = "ZkCitationBrackets",
            conceal = "",
            priority = 200,
          })
          start_idx = e + 1
        end
      end
    end

    -- Evita que las palabras clave de tus citas {{citekey}} se marquen como errores
    -- ortográficos (subrayado rojo de spell) definiendo una regla de sintaxis con @NoSpell.
    local function apply_nospell(bufnr)
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd([[syntax match ZkCitationNoSpell /{{[^[:space:]{}]\+}}/ contains=@NoSpell]])
      end)
    end

    -- Mapeos locales de buffer para auto-cerrar [[ y {{ en archivos markdown
    -- Esto soluciona los problemas de autocompletado en la última línea del archivo
    -- o entre dos líneas con texto, asegurando que la sintaxis siempre esté cerrada.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.keymap.set("i", "[[", "[[]]<Left><Left>", { buffer = true, desc = "Auto-close wiki-link" })
        vim.keymap.set("i", "{{", "{{}}<Left><Left>", { buffer = true, desc = "Auto-close citation" })
      end,
    })

    vim.api.nvim_create_autocmd({
      "BufEnter",
      "BufWritePost",
      "TextChanged",
      "InsertLeave",
      "CursorMoved",
    }, {
      group = vim.api.nvim_create_augroup("ZkCitationsGroup", { clear = true }),
      pattern = "*.md",
      callback = function(ev)
        if ev.event == "BufWritePost" then
          local note_id = vim.fn.fnamemodify(ev.file, ":t:r")
          title_cache[note_id] = nil
        end
        highlight_citations(ev.buf)
        highlight_wikilinks(ev.buf)
        apply_nospell(ev.buf)
      end,
    })
    -- Abrir o crear nota bibliográfica desde una píldora {{citekey}}
    vim.keymap.set("n", "gB", function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Basado en 1 para strings de Lua

      -- Buscar si hay una cita {{...}} bajo el cursor
      local start_idx = 1
      local target_citekey = nil

      while true do
        local s, e, full = string.find(line, "{{([^%s{}]+)}}", start_idx)
        if not s then
          break
        end

        if col >= s and col <= e then
          target_citekey = full:match("^([^:]+)")
          break
        end
        start_idx = e + 1
      end

      -- Si encontramos la píldora bajo el cursor
      if target_citekey then
        local bib_path = "/Users/fabsanh/Mesh/Bibliografía/" .. target_citekey .. ".md"

        if vim.fn.filereadable(bib_path) == 1 then
          -- El archivo existe: lo abrimos normal
          vim.cmd("edit " .. vim.fn.fnameescape(bib_path))
        else
          -- El archivo NO existe: lanzamos la ventana emergente de LazyVim
          vim.ui.select({ "Sí, crear", "No, cancelar" }, {
            prompt = "La referencia '" .. target_citekey .. "' no existe. ¿Deseas crearla?",
          }, function(choice)
            -- Este bloque se ejecuta cuando elijas una opción en el menú flotante
            if choice == "Sí, crear nota" then
              -- 1. Abre un buffer nuevo con la ruta
              vim.cmd("edit " .. vim.fn.fnameescape(bib_path))
              -- 2. Fuerza un guardado inmediato para que zk-nvim lo indexe al instante
              vim.cmd("write")
              -- 3. Avisa que todo salió bien
              vim.notify("Nota creada: " .. target_citekey, vim.log.levels.INFO)
            end
          end)
        end
      else
        vim.notify("No hay una cita bibliográfica bajo el cursor.", vim.log.levels.INFO)
      end
    end, { desc = "ZkZettel: Abrir/Crear nota de Bibliografía" })

    -- =============================================================================
    -- 0. CONFIGURACIÓN Y COMANDOS PERSONALIZADOS
    -- =============================================================================
    local zk = require("zk")
    local commands = require("zk.commands")

    -- Registra el comando personalizado para buscar notas huérfanas
    commands.add("ZkOrphans", function(options)
      options = vim.tbl_extend("force", { orphan = true }, options or {})
      zk.edit(options, { title = "Zk Orphans" })
    end)

    -- =============================================================================
    -- KEYMAPS PARA ZK (NOTE-TAKING)
    -- =============================================================================

    --------------------------------------------------------------------------------
    -- 1. Creación de Notas
    --------------------------------------------------------------------------------

    -- Crear una nota general solicitando un título al usuario (Con validación)
    vim.keymap.set("n", "<leader>zN", function()
      local title = vim.fn.input("Note Title: ")
      if title ~= "" then
        require("zk").new({ title = title })
      end
    end, { desc = "Zk New Note" })

    -- Crear la nota diaria para el día de hoy con una plantilla predefinida
    vim.keymap.set(
      "n",
      "<leader>zd",
      "<Cmd>ZkNew { title = os.date('%Y-%m-%d'), dir = 'Journal', template = 'journal.md' }<CR>",
      { desc = "Zk Today's Daily Note" }
    )

    -- Crear una nota diaria para una fecha personalizada (ej. yyyymmdd)
    vim.keymap.set("n", "<leader>zD", function()
      local title = vim.fn.input("Date (yyyymmdd): ")
      if title ~= "" then
        require("zk").new({
          group = "journal",
          dir = "Journal",
          title = title,
          extension = "md",
        })
      end
    end, { desc = "Zk New Daily Note" })

    -- Crear una nota bibliográfica dentro de la carpeta específica
    vim.keymap.set("n", "<leader>zB", function()
      local title = vim.fn.input("Bibnote Title (AuthorYear): ")
      if title ~= "" then
        require("zk").new({
          group = "bibliography",
          dir = "Bibliografía",
          title = title,
          extension = "md",
        })
      end
    end, { desc = "Zk New Bibnote" })

    --------------------------------------------------------------------------------
    -- 2. Búsqueda y Filtrado
    --------------------------------------------------------------------------------

    -- Buscar notas que contengan un término de texto ingresado (Con validación)
    vim.keymap.set("n", "<leader>zs", function()
      local search = vim.fn.input("Search: ")
      if search ~= "" then
        require("zk").edit({ match = { search } })
      end
    end, { desc = "Zk Search Notes" })

    -- Buscar notas que coincidan exactamente con el texto seleccionado en modo Visual
    vim.keymap.set("v", "<leader>zs", ":'<,'>ZkMatch<CR>", { desc = "Zk Match Selection" })

    -- Filtrar y buscar notas que contengan una etiqueta específica (Con validación)
    vim.keymap.set("n", "<leader>zf", function()
      local tag = vim.fn.input("Tag: ")
      if tag ~= "" then
        require("zk").edit({ tags = { tag } })
      end
    end, { desc = "Zk Find by Tag" })

    -- Buscar notas huérfanas (aquellas que no tienen enlaces entrantes ni salientes)
    vim.keymap.set("n", "<leader>zo", "<Cmd>ZkOrphans<CR>", { desc = "Zk Find Orphans" })

    --------------------------------------------------------------------------------
    -- 3. Navegación, Listado y Ordenación
    --------------------------------------------------------------------------------

    -- Examinar/listar todas las notas del directorio de trabajo
    vim.keymap.set("n", "<leader>zn", "<Cmd>ZkNotes<CR>", { desc = "Zk Notes" })

    -- Listar y navegar por todas las etiquetas (tags) disponibles
    vim.keymap.set("n", "<leader>zt", "<Cmd>ZkTags<CR>", { desc = "Zk Browse Tags" })

    --------------------------------------------------------------------------------
    -- 4. Utilidades del Sistema e Indexación
    --------------------------------------------------------------------------------

    -- Insertar interbúsqueda de un enlace (link) hacia otra nota en la posición del cursor
    vim.keymap.set("n", "<leader>zi", "<Cmd>ZkInsertLink { sort = { 'modified' } } <CR>", { desc = "Zk Insert Link" })

    -- Forzar la indexación manual de zk para actualizar los enlaces y metadatos
    vim.keymap.set("n", "<leader>zI", "<Cmd>ZkIndex<CR>", { desc = "Zk Index" })

    -- Insertar referencia bibliográfica del estilo {{citekey}} en la posición del cursor
    vim.keymap.set("n", "<leader>zc", "<Cmd>ZkInsertCite<CR>", { desc = "Zk Insert Citation" })
  end,
}
