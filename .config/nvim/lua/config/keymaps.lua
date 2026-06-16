-- LSP-specific mappings for inside note buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local opts = { buffer = true }
    -- Open the note under the cursor
    vim.keymap.set("n", "gd", "<Cmd>ZkCd<CR>", opts)
    -- Automatically link visual selections to new/existing notes
    vim.keymap.set("v", "<leader>zll", ":'<,'>ZkMatch<CR>", opts)
  end,
})
