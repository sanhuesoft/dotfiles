return {
  "ibhagwan/fzf-lua",
  opts = function(_, opts)
    -- Configuraciones globales de la interfaz
    opts.show_header_binds = false
    opts.defaults = opts.defaults or {}
    opts.defaults.headers = false
    opts.files = {
      headers = false,
      hidden = false,
    }
  end,
  keys = {
    -- Búsqueda de archivos y buffers
    { "<C-o>", "<cmd>FzfLua files<cr>", desc = "FzfLua find files" },
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "FzfLua find files" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "FzfLua buffers" },
    { "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "FzfLua oldfiles" },

    -- Búsqueda de texto (Grep)
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "FzfLua live grep" },
    { "<leader>fz", "<cmd>FzfLua grep<cr>", desc = "FzfLua grep" }, -- Corregido el duplicado

    -- Historial y Tags
    { "<leader>fh", "<cmd>FzfLua history<cr>", desc = "FzfLua history" },
    { "<leader>ft", "<cmd>FzfLua tags<cr>", desc = "FzfLua tags" },
  },
}
