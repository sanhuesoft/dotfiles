-- LSP-specific mappings for inside note buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local opts = { buffer = true, silent = true, nowait = true }

    -- 1. Eliminamos el comando ruidoso :ZkCd que detonaba los duplicados
    -- y dejamos que actúe nuestro resolvedor de zk-nvim.lua
    -- Si por alguna razón quieres mapearlo aquí directamente, usamos el view_note síncrono:
    vim.keymap.set("n", "gd", function()
      require("zk").view_note()
    end, opts)

    -- Automatically link visual selections to new/existing notes
    vim.keymap.set("v", "<leader>zll", ":'<,'>ZkMatch<CR>", opts)
  end,
})
