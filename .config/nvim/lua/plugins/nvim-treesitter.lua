return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "markdown",
      "markdown_inline",
      "vim",
      "vimdoc",
      "query",
      "regex",
      "bash",
    },
    highlight = {
      enable = true,
    },
  },
}
