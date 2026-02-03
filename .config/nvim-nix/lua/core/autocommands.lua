-- Autocommands for Neovim 0.11.x

-- Highlight on yank (0.11-compatible: use vim.highlight instead of vim.hl)
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

-- Spell check for certain file types
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('SpellCheck', { clear = true }),
  pattern = { 'markdown', 'quarto', 'gitcommit' },
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- Enable treesitter highlighting for markdown (required for render-markdown)
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('MarkdownTreesitter', { clear = true }),
  pattern = { 'markdown', 'quarto' },
  callback = function()
    vim.treesitter.start()
  end,
})

-- Line numbers in help windows
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('HelpLineNumbers', { clear = true }),
  pattern = 'help',
  callback = function()
    vim.opt_local.number = true
    vim.opt_local.relativenumber = true
  end,
})

-- Terminal settings
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('TerminalSettings', { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})

-- Auto-resize windows on vim resize
vim.api.nvim_create_autocmd('VimResized', {
  group = vim.api.nvim_create_augroup('ResizeWindows', { clear = true }),
  callback = function()
    vim.cmd('wincmd =')
  end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('RestoreCursor', { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- LSP keymaps and settings on attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspConfig', { clear = true }),
  callback = function(args)
    local bufnr = args.buf

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings
    local opts = { buffer = bufnr, silent = true }

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>ln', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>lh', vim.lsp.buf.signature_help, opts)
  end,
})
