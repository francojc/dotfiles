-- Description: Custom keymaps
--

local keymap = vim.keymap -- for convenience

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

keymap.set('i', 'jj', '<ESC>', { desc = 'jj to <ESC>' })

keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

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

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

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
