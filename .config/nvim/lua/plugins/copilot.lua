return {
  "github/copilot.vim",
  init = function()
    -- Desactiva Copilot específicamente para el tipo de archivo markdown
    vim.g.copilot_filetypes = {
      markdown = false,
      text = false,
      Ramos = false, -- Por si acaso usas otra extensión
    }
  end,
}
