-- Autocommands

a = vim.api 

-- Create an autocommand group --------------------------------------
-- personal

a.nvim_create_augroup("personal", { clear = true }) 

a.nvim_create_autocmd('TextYankPost', {
  group = "personal",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
})
