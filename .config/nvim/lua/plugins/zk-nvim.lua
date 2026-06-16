-- Configuración del plugin zk-nvim y renderizado personalizado de citas Zk
-- En este archivo se maneja la integración con zk y la estética de las referencias {{citekey}}
return {
  --- "zk-org/zk-nvim",
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
    -- CONFIGURACIÓN DE HIGHLIGHTS Y FORMATO DE CITAS {{referencia}}
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

    -- Grupo de highlight para las llaves contenedoras {{ y }}
    -- Utiliza un color gris oscuro para atenuar o esconder visualmente las llaves
    vim.api.nvim_set_hl(
      0,
      "ZkCitationBrackets",
      { fg = "#585b70", nocombine = true }
    )

    -- Escuchar cambios de tema (ColorScheme) para reinstaurar los highlights
    -- y evitar que nuevos temas pisen los colores específicos de ZkCitation
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        vim.api.nvim_set_hl(0, "ZkCitation", zk_hl)
        vim.api.nvim_set_hl(
          0,
          "ZkCitationBrackets",
          { fg = "#585b70", nocombine = true }
        )
      end,
    })

    -- Escuchar cuando un cliente LSP se adjunta (LspAttach)
    -- Si el cliente es "zk", fuerza la redefinición de ZkCitation para evitar
    -- que los tokens semánticos del servidor LSP anulen o apaguen el estilo
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "zk" then
          vim.api.nvim_set_hl(0, "ZkCitation", zk_hl)
        end
      end,
    })

    -- Espacio de nombres exclusivo para las marcas virtuales (extmarks) de citas
    local namespace = vim.api.nvim_create_namespace("ZkCitations")

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
          -- Buscar citas con formato especial que incluyan páginas o rangos (ej. {{Key:25-27}}, {{Key.etal2023:25}})
          local s, e, full =
            string.find(line, "{{([%w%-_.:]+-?[%d]*)}}", start_idx)
          if not s then
            -- Búsqueda de respaldo más general para capturar citekeys simples
            s, e, full = string.find(line, "{{([%w%-_.:]+)}}", start_idx)
          end
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
          vim.api.nvim_buf_set_extmark(
            bufnr,
            namespace,
            line_num,
            open_bracket_start,
            {
              end_col = open_bracket_end,
              hl_group = "ZkCitationBrackets",
              conceal = "",
              virt_text = { { "󰂺 ", "ZkCitation" } },
              virt_text_pos = "inline",
              hl_mode = "replace",
              priority = 200,
            }
          )

          -- Clave de cita: Aplicar estilo visual de ZkCitation sin subrayar el icono de libro
          vim.api.nvim_buf_set_extmark(
            bufnr,
            namespace,
            line_num,
            open_bracket_end,
            {
              end_col = citekey_end,
              hl_group = "ZkCitation",
              hl_mode = "replace",
              priority = 200,
            }
          )

          -- Números de página (si existen): Ocultar el sufijo ':páginas' de la vista normal
          if pages_part then
            vim.api.nvim_buf_set_extmark(
              bufnr,
              namespace,
              line_num,
              citekey_end,
              {
                end_col = close_bracket_start,
                hl_group = "ZkCitationBrackets",
                conceal = "",
                priority = 200,
              }
            )
          end

          -- Llaves de cierre: Ocultar '}}' por completo
          vim.api.nvim_buf_set_extmark(
            bufnr,
            namespace,
            line_num,
            close_bracket_start,
            {
              end_col = close_bracket_end,
              hl_group = "ZkCitationBrackets",
              conceal = "",
              priority = 200,
            }
          )
          start_idx = e + 1
        end
      end
    end

    -- Evita que las palabras clave de tus citas {{citekey}} se marquen como errores
    -- ortográficos (subrayado rojo de spell) definiendo una regla de sintaxis con @NoSpell.
    local function apply_nospell(bufnr)
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd(
          [[syntax match ZkCitationNoSpell /{{[[:alnum:]_.\:-]\+}}/ contains=@NoSpell]]
        )
      end)
    end

    -- Monitorear eventos del buffer para actualizar las marcas visuales y desactivar
    -- el corrector ortográfico en tiempo real cuando se edita, carga o guarda un markdown.
    vim.api.nvim_create_autocmd(
      { "BufEnter", "BufWritePost", "TextChanged", "TextChangedI" },
      {
        group = vim.api.nvim_create_augroup(
          "ZkCitationsGroup",
          { clear = true }
        ),
        pattern = "*.md",
        callback = function(ev)
          highlight_citations(ev.buf)
          apply_nospell(ev.buf)
        end,
      }
    )
    -- Abrir o crear nota bibliográfica desde una píldora {{citekey}}
    vim.keymap.set("n", "gB", function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Basado en 1 para strings de Lua

      -- Buscar si hay una cita {{...}} bajo el cursor
      local start_idx = 1
      local target_citekey = nil

      while true do
        local s, e, citekey = string.find(line, "{{([%w%-_]+)}}", start_idx)
        if not s then
          break
        end

        if col >= s and col <= e then
          target_citekey = citekey
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
            prompt = "La referencia '"
              .. target_citekey
              .. "' no existe. ¿Deseas crearla?",
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
        vim.notify(
          "No hay una cita bibliográfica bajo el cursor.",
          vim.log.levels.INFO
        )
      end
    end, { desc = "ZkZettel: Abrir/Crear nota de Bibliografía" })

    -- Normal mode mappings
    -- Browse all notes
    vim.keymap.set("n", "<leader>zn", "<Cmd>ZkNotes<CR>", { desc = "Zk Notes" })

    -- Find notes based on a search term
    vim.keymap.set(
      "n",
      "<leader>zs",
      "<Cmd>ZkNotes { match = { vim.fn.input('Search: ') } }<CR>",
      { desc = "Zk Search Notes" }
    )
    -- Find notes matching the current visual selection
    vim.keymap.set(
      "v",
      "<leader>zs",
      ":'<,'>ZkMatch<CR>",
      { desc = "Zk Match Selection" }
    )

    -- Find notes by tags
    vim.keymap.set(
      "n",
      "<leader>zt",
      "<Cmd>ZkTags<CR>",
      { desc = "Zk Browse Tags" }
    )
    vim.keymap.set(
      "n",
      "<leader>zf",
      "<Cmd>ZkNotes { tags = { vim.fn.input('Tag: ') } }<CR>",
      { desc = "Zk Find by Tag" }
    )

    -- Daily note actions
    vim.keymap.set(
      "n",
      "<leader>zd",
      "<Cmd>ZkNew { title = os.date('%Y-%m-%d'), dir = 'Journal' }<CR>",
      { desc = "Zk Daily Note" }
    )

    -- Creation shortcuts
    vim.keymap.set(
      "n",
      "<leader>zN",
      "<Cmd>ZkNew { title = vim.fn.input('Note Title: ') }<CR>",
      { desc = "Zk New Note" }
    )

    -- ZkOrphans Shortcut
    vim.keymap.set(
      "n",
      "<leader>zo",
      "<Cmd>ZkOrphans<CR>",
      { desc = "Zk Find Orphans" }
    )

    local zk = require("zk")
    local commands = require("zk.commands")

    commands.add("ZkOrphans", function(options)
      options = vim.tbl_extend("force", { orphan = true }, options or {})
      zk.edit(options, { title = "Zk Orphans" })
    end)
  end,
}
