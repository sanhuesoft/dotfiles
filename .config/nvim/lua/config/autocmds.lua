-- Disable LazyVim's default wrap_spell autogroup to prevent it from enabling spell check
pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")

-- En Mesh ajusta tw=80 y nowrap automáticamente
vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
  group = vim.api.nvim_create_augroup("ZettelkastenFormat", { clear = true }),
  -- REEMPLAZA esta ruta por la carpeta exacta que quieras trackear (ej. tu bóveda de notas)
  pattern = "/Users/fabsanh/Mesh/*",
  callback = function()
    vim.opt_local.wrap = false -- Equivale a: setlocal nowrap
    vim.opt_local.textwidth = 80 -- Equivale a: setlocal textwidth=80
  end,
})
