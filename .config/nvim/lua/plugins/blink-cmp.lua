return {
  "saghen/blink.cmp",
  opts = {
    -- =========================================================================
    -- CONTROL DE ACTIVACIÓN CONTEXTUAL
    -- =========================================================================
    -- Evitamos usar 'enabled' dinámicamente porque blink.cmp registra sus atajos
    -- de teclado durante InsertEnter. Si 'enabled' retorna falso al entrar en
    -- modo insert, los atajos de teclado no se registran. En su lugar, usamos
    -- 'completion.menu.auto_show' para decidir cuándo mostrar el menú.
    keymap = {
      preset = "default", -- Mantiene los atajos por defecto de LazyVim
      ["<C-Space>"] = { "show", "show_documentation", "hide" }, -- Invoca o esconde el menú

      -- NAVEGACIÓN NATIVA VIM
      ["<C-n>"] = {
        function(cmp)
          if cmp.is_menu_visible() then
            cmp.select_next()
            return true
          end
        end,
        "fallback",
      },
      ["<C-p>"] = {
        function(cmp)
          if cmp.is_menu_visible() then
            cmp.select_prev()
            return true
          end
        end,
        "fallback",
      },

      -- EL COMBO NATIVO COMPLETO
      ["<C-y>"] = { "select_and_accept", "fallback" }, -- Control + y (Yes) acepta la sugerencia
      ["<C-e>"] = { "hide", "fallback" }, -- Control + e (Exit) aborta y cierra el menú
    },
    completion = {
      ghost_text = {
        enabled = function()
          if vim.bo.filetype == "markdown" then
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before_cursor = line:sub(1, col)

            local inside_wiki = before_cursor:match(".*%[%[[^%]]*$") ~= nil
            local inside_zk = before_cursor:match(".*{{[^}]*$") ~= nil

            return inside_wiki or inside_zk
          end
          return true
        end,
      },
      trigger = {
        -- Disable the default behavior that blocks spaces, tabs, and newlines
        blocked_trigger_characters = {},
      },
      menu = {
        auto_show = function(ctx)
          -- Desactivar en buffers especiales (como terminales o ventanas de comandos)
          if vim.bo.buftype == "prompt" then
            return false
          end

          local line = ctx.line
          local col = ctx.cursor[2]
          local before_cursor = line:sub(1, col)

          -- Expresiones regulares de Lua para detectar delimitadores abiertos:
          local inside_wiki = before_cursor:match(".*%[%[[^%]]*$") ~= nil
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
          preselect = true, -- Sigue siendo útil para que el primer elemento ya esté marcado
        },
      },
    },
    sources = {
      default = { "bibman" },
      providers = {
        bibman = {
          module = "blink.cmp.sources.bibman",
          name = "Bibliografía",
          score_offset = 100,
        },
        lsp = {
          -- Allow space to trigger suggestions in your LSP
          override = {
            get_trigger_characters = function(self)
              local trigger_characters = self:get_trigger_characters()
              vim.list_extend(trigger_characters, { ' ', '\n', '\t' })
              return trigger_characters
            end,
          },
        },
      },
    },
  },
}
