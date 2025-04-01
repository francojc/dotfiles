-- Autocommands

a = vim.api 

-- Create an autocommand group --------------------------------------
-- personal

a.nvim_create_augroup("personal", { clear = true }) 

-- Highlight on yank
a.nvim_create_autocmd('TextYankPost', {
  group = "personal",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Autocompletion (Nvim .11+)
a.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

