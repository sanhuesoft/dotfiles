return {
  "stevearc/aerial.nvim",
  opts = {},
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("aerial").setup({
      -- Prioriza Tree-sitter para reconocer los encabezados de Markdown
      backends = { "treesitter", "markdown", "lsp" },

      layout = {
        max_width = { 40, 0.2 },
        width = nil,
        min_width = 30,
        win_opts = {
          winhl = "Normal:NormalSB,SignColumn:SignColumnSB",
          signcolumn = "no",
          foldcolumn = "0",
        },
      },

      -- Controla qué se muestra. En Markdown queremos los encabezados.
      filter_kind = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Module",
        "Method",
        "Struct",
      },

      -- Teclas de navegación dentro del árbol de Aerial
      keymaps = {
        ["?"] = "actions.show_help",
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.jump",
        ["<2-LeftMouse>"] = "actions.jump",
        ["<C-v>"] = "actions.jump_vsplit",
        ["<C-s>"] = "actions.jump_split",
        ["p"] = "actions.scroll",
        ["<C-j>"] = "actions.down_and_scroll",
        ["<C-k>"] = "actions.up_and_scroll",
        ["{"] = "actions.prev",
        ["}"] = "actions.next",
        ["[["] = "actions.prev_up",
        ["]]"] = "actions.next_up",
        ["q"] = "actions.close",
        ["o"] = "actions.tree_toggle",
        ["za"] = "actions.tree_toggle",
        ["O"] = "actions.tree_toggle_recursive",
        ["zA"] = "actions.tree_toggle_recursive",
        ["l"] = "actions.tree_open",
        ["zo"] = "actions.tree_open",
        ["L"] = "actions.tree_open_recursive",
        ["zO"] = "actions.tree_open_recursive",
        ["h"] = "actions.tree_close",
        ["zc"] = "actions.tree_close",
        ["H"] = "actions.tree_close_recursive",
        ["zC"] = "actions.tree_close_recursive",
        ["e"] = "actions.tree_toggle_item",
        ["M"] = "actions.tree_set_fold_level",
        ["R"] = "actions.tree_sync_folds",
      },
    })

    -- Atajo de teclado para abrir/cerrar el árbol (ejemplo: <leader>a)
    vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial (Outline)" })
  end,
}
