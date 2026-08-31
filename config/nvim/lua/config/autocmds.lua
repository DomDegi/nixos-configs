-- Open PDFs in zathura instead of trying to render them as a buffer.
vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = "*.pdf",
  callback = function(opts)
    local filepath = vim.fn.expand(opts.file)
    vim.fn.jobstart({ "zathura", filepath }, { detach = true })
    vim.api.nvim_buf_delete(opts.buf, { force = true })
  end,
})
