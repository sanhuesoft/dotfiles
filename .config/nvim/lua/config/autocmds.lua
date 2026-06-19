-- Disable LazyVim's default wrap_spell autogroup to prevent it from enabling spell check
pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")

-- En Mesh ajusta tw=80 y nowrap automáticamente para markdown
vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
  group = vim.api.nvim_create_augroup("ZettelkastenFormat", { clear = true }),
  pattern = "*.md", -- Se activa para cualquier archivo markdown
  callback = function()
    -- Obtenemos la ruta absoluta del archivo actual
    local buf_name = vim.api.nvim_buf_get_name(0)

    -- Verificamos si el archivo está dentro de la carpeta Mesh
    -- (Ajustamos para que use el directorio home del usuario de forma segura)
    local mesh_path = vim.fn.expand("~/Mesh/")

    if buf_name:find(mesh_path, 1, true) then
      vim.opt_local.wrap = false
      vim.opt_local.textwidth = 80
    end
  end,
})
