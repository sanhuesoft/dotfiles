return {
  "lukas-reineke/indent-blankline.nvim",
  opts = {
    indent = { highlight = { "LineNr" } },
    scope = { enabled = true }, --, highlight = "Function" },
    exclude = {
      filetypes = {
        "markdown",
      },
    },
  },
  main = "ibl",
  config = function(_, opts)
    -- 1. Inicializamos el plugin con tus opciones de arriba
    require("ibl").setup(opts)

    -- 2. Vinculamos 'IblScope' al color de las funciones de tu tema activo
    local hooks = require("ibl.hooks")
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "IblScope", { link = "Function" })
    end)
  end,
}
