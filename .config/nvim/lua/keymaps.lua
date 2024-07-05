-- Description: Custom keymaps

local keymap = vim.keymap -- for convenience

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
keymap.set('i', 'jj', '<ESC>', { desc = 'jj to <ESC>' })
keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- TIP: Disable arrow keys in normal mode
keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  See `:help wincmd` for a list of all window commands
keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Diagnostic keymaps
keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Codecompanion keymaps
keymap.set({ 'n', 'v' }, '<leader>an', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true, desc = 'Open CodeCompanion actions palette' })
keymap.set({ 'n', 'v' }, '<leader>at', '<cmd>CodeCompanionToggle<cr>', { noremap = true, silent = true, desc = 'Toggle CodeCompanion chat window' })
keymap.set('v', '<leader>aa', '<cmd>CodeCompanionAdd<cr>', { noremap = true, silent = true, desc = 'Add selection to CodeCompanion' })

-- Expand `cc` into CodeCompanion in the command line
vim.cmd [[cab cc CodeCompanion]]
vim.cmd [[cab ccb CodeCompanionWithBuffers]]

-- Todo-comments keymaps
keymap.set('n', '<leader>td', '<cmd>TodoTelescope<cr>', { desc = 'Search [T]odo comments' })
keymap.set('n', ']t', function()
  require('todo-comments').jump_next { keywords = { 'TODO', 'FIXME' } }
end, { desc = 'Jump to next [T]odo comment' })
keymap.set('n', '[t', function()
  require('todo-comments').jump_prev { keywords = { 'TODO', 'FIXME' } }
end, { desc = 'Jump to previous [T]odo comment' })

-- Barbar keymaps
-- See `:help barbar`
keymap.set('n', '<A-c>', '<Cmd>BufferClose<CR>', { noremap = true, silent = true, desc = 'Close buffer' })
keymap.set('n', '<A-,>', '<Cmd>BufferNext<CR>', { noremap = true, silent = true, desc = 'Next buffer' })
keymap.set('n', '<A-.>', '<Cmd>BufferPrevious<CR>', { noremap = true, silent = true, desc = 'Previous buffer' })
keymap.set('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', { noremap = true, silent = true, desc = 'Order by buffer number' })
keymap.set('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', { noremap = true, silent = true, desc = 'Order by directory' })
keymap.set('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', { noremap = true, silent = true, desc = 'Order by language' })
keymap.set('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', { noremap = true, silent = true, desc = 'Go to buffer 1' })
keymap.set('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', { noremap = true, silent = true, desc = 'Go to buffer 2' })
keymap.set('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', { noremap = true, silent = true, desc = 'Go to buffer 3' })
keymap.set('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', { noremap = true, silent = true, desc = 'Go to buffer 4' })
keymap.set('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', { noremap = true, silent = true, desc = 'Go to buffer 5' })
keymap.set('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', { noremap = true, silent = true, desc = 'Go to buffer 6' })
keymap.set('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', { noremap = true, silent = true, desc = 'Go to buffer 7' })
keymap.set('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', { noremap = true, silent = true, desc = 'Go to buffer 8' })
keymap.set('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', { noremap = true, silent = true, desc = 'Go to buffer 9' })
keymap.set('n', '<A-0>', '<Cmd>BufferLast<CR>', { noremap = true, silent = true, desc = 'Go to last buffer' })

-- vim-slime keymaps
-- See `:help vim-slime`
-- Send region
keymap.set('x', '<leader>sl', '<Plug>SlimeRegionSend', { desc = '[S]end current [l]ine to tmux pane' })
-- Send paragraph
keymap.set('n', '<leader>sp', '<Plug>SlimeParagraphSend', { desc = '[S]end current [p]aragraph to tmux pane' })
-- Send file
keymap.set('n', '<leader>sc', '<Plug>SlimeConfig<CR><Plug>SlimeFileSend', { desc = '[S]end [c]omplete file to tmux pane' })

-- Aerial code outline toggle
vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>')

-- [[ Macros ]]
vim.g['a'] = 'yWea\\index{<C-r>"}<Esc>'
keymap.set('n', '<leader>ab', '@a', { noremap = true, silent = true, desc = 'Add a new index entry' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Custom save function with trailing whitespace removal
local function remove_trailing_whitespace()
  local save_cursor = vim.fn.getpos '.'
  vim.cmd [[%s/\s\+$//e]]
  vim.fn.setpos('.', save_cursor)
end

-- Create an autocommand group
vim.api.nvim_create_augroup('CustomSave', { clear = true })

-- Define the autocommand to remove trailing whitespace before saving
vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'CustomSave',
  callback = remove_trailing_whitespace,
})

-- Map <leader>w to trigger the autocommand and save the file
keymap.set('n', '<leader>w', function()
  vim.cmd 'doautocmd CustomSave BufWritePre'
  vim.cmd 'write'
end, { noremap = true, silent = true, desc = 'Save and trim whitespace' })
