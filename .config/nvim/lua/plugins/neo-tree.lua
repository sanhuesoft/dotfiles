return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<C-e>", "<cmd>Neotree filesystem reveal left<cr>", desc = "Neotree reveal" },
  },
  config = function()
    require("neo-tree").setup({
      window = {
        width = 30,
      },
    })
  end,
}
