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
        -- Nota: ghost_text.enabled nativamente prefiere un booleano.
        -- Si notas que no se refresca dinámicamente, déjalo en true,
        -- ya que auto_show abajo se encargará de limitar cuándo se despliega todo.
        enabled = true,
      },
      -- Se eliminó la sección 'trigger = { blocked_trigger_characters = {} }' que causaba el error
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
          -- Aquí ya estás forzando a que acepte espacios y saltos de línea para el LSP,
          -- lo cual suple por completo lo que intentabas hacer con 'blocked_trigger_characters'
          override = {
            get_trigger_characters = function(self)
              local trigger_characters = self:get_trigger_characters()
              vim.list_extend(trigger_characters, { " ", "\n", "\t" })
              return trigger_characters
            end,
          },
        },
      },
    },
  },
}
