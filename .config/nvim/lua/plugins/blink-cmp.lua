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
      ["<C-n>"] = { "select_next", "fallback" }, -- Control + n va al siguiente resultado
      ["<C-p>"] = { "select_prev", "fallback" }, -- Control + p va al resultado anterior

      -- EL COMBO NATIVO COMPLETO
      ["<C-y>"] = { "select_and_accept", "fallback" }, -- Control + y (Yes) acepta la sugerencia
      ["<C-e>"] = { "hide", "fallback" }, -- Control + e (Exit) aborta y cierra el menú
    },
    completion = {
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
      },
    },
  },
}
