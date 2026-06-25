return {
  "saghen/blink.cmp",
  opts = {
    -- =========================================================================
    -- CONTROL DE ACTIVACIÓN CONTEXTUAL
    -- =========================================================================
    keymap = {
      preset = "default", -- Mantiene los atajos por defecto de LazyVim
      ["<C-Space>"] = { "show", "show_documentation", "hide" }, -- Invoca o esconde el menú

      -- NAVEGACIÓN NATIVA VIM
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },

      -- EL COMBO NATIVO COMPLETO
      ["<C-y>"] = { "select_and_accept", "fallback" }, -- Control + y (Yes) acepta la sugerencia
      ["<C-e>"] = { "hide", "fallback" }, -- Control + e (Exit) aborta y cierra el menú
    },
    completion = {
      ghost_text = {
        enabled = false,
      },
      menu = {
        auto_show = function(ctx)
          if vim.bo.buftype == "prompt" then
            return false
          end

          local line = ctx.line
          local col = ctx.cursor[2]
          local before_cursor = line:sub(1, col)

          local inside_wiki = before_cursor:match(".*%[%[%s*[^%]]*$") ~= nil
          local inside_zk = before_cursor:match(".*{{[^}]*$") ~= nil

          return inside_wiki or inside_zk
        end,
        draw = {
          components = {
            label = {
              highlight = function(ctx)
                if ctx.source_name == "Bibliografía" or ctx.source_id == "bibman" then
                  return "ZkCitationMenu"
                end
                return "BlinkCmpLabel"
              end,
            },
          },
        },
      },
      list = {
        selection = {
          preselect = true,
        },
      },
    },
    sources = {
      -- Función dinámica para alternar fuentes según el contexto
      default = function()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local before_cursor = line:sub(1, col)

        -- Contexto 1: Dentro de llaves dobles {{ (Bibliografía / Citas)
        if before_cursor:match(".*{{[^}]*$") then
          -- Forzamos a que SOLO use la fuente de bibliografía
          return { "bibman" }
        end

        -- Contexto 2: Dentro de enlaces Wiki [[ (Notas generales)
        if before_cursor:match(".*%[%[%s*[^%]]*$") then
          -- Mantiene el LSP para indexar los títulos de las notas
          return { "lsp" }
        end

        -- Contexto General: Fuera de delimitadores de Zettelkasten
        return { "lsp", "path", "snippets", "buffer" }
      end,
      providers = {
        bibman = {
          module = "blink.cmp.sources.bibman",
          name = "Bibliografía",
          score_offset = 100,
        },
        lsp = {
          -- Forzamos al LSP a no meter texto fantasma inline (ghost_text)
          -- y filtramos para que NO sugiera texto plano ('Text') dentro de los corchetes
          transform_items = function(ctx, items)
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before_cursor = line:sub(1, col)
            local inside_wiki = before_cursor:match(".*%[%[%s*[^%]]*$") ~= nil

            local seen = {}
            return vim.tbl_filter(function(item)
              -- Si estamos dentro de [[, descartamos completados tipo "Text" (palabras sueltas del buffer/LSP)
              if inside_wiki and item.kind == vim.lsp.protocol.CompletionItemKind.Text then
                return false
              end

              if seen[item.label] then
                return false
              end
              seen[item.label] = true
              return true
            end, items)
          end,
        },
      },
    },
  },
}
