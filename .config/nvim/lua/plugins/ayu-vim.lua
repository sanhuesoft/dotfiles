return {
  {
    "Luxed/ayu-vim",
    name = "ayu-vim",
    lazy = false,
    priority = 1000,
    init = function()
      -- Enable true colors support
      vim.opt.termguicolors = true
      -- Set background and flavor as per instructions
      -- "light" for light version, "dark" for mirage or dark version
      vim.opt.background = "dark"
      -- Flavor options: "light", "mirage", "dark"
      vim.g.ayucolor = "dark"
      vim.g.ayu_italic_comment = true

      -- Aclarar el texto principal (Normal fg) a un gris claro agradable
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "ayu",
        callback = function()
          vim.api.nvim_set_hl(0, "Normal", { fg = "#f1f1f1" })
        end,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ayu",
    },
  },
}
