-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- General Keymaps -------------------

-- save file
keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- use jk to exit insert mode
keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- past without overwriting
keymap.set("v", "p", '"P')

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab
keymap.set("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Close all buffer execept current" }) -- close buffer

-- R specific keymaps -------------------
-- R keymaps
keymap.set("i", "<M>-", " <- ", { expr = true, noremap = true, silent = true, desc = "Insert <- (assignment)" })
keymap.set("i", "<M>p", " |> ", { expr = true, noremap = true, silent = true, desc = "Insert |> (pipe)" })

-- LSP Keymaps -------------------
-- Copilot keymaps
-- <TAB> to trigger completion
keymap.set("i", '<C-J>', '<Plug>(copilot-accept-word)')
keymap.set("i", '<C-L>', '<Plug>(copilot-accept-line)')
keymap.set("i", '<C-\\>', '<Plug>(copilot-next)')

-- Codecompanion keymaps
keymap.set("n", "<leader>na", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
keymap.set("v", "<leader>na", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
keymap.set("n", "<leader>a", "<cmd>CodeCompanionToggle<cr>", { noremap = true, silent = true })
keymap.set("v", "<leader>a", "<cmd>CodeCompanionToggle<cr>", { noremap = true, silent = true })
keymap.set("v", "ga", "<cmd>CodeCompanionAdd<cr>", { noremap = true, silent = true })

-- Expand `cc` into CodeCompanion in the command line
vim.cmd([[cab cc CodeCompanion]])
vim.cmd([[cab ccb CodeCompanionWithBuffers]])

-- Slime keymaps
-- Send line to REPL <C-c><C-c>
-- Send code block to REPL
keymap.set("n", "<leader>sb", "<Plug>SlimeSendCell", { desc = "Send cell to REPL" })

-- Macro Keymaps -------------------
-- Macro to insert index (1, 2, or 3 words)
vim.g['a'] = 'yWea\\index{<C-r>0}<ESC>'
keymap.set('n', '<leader>ab', '@a', { noremap = true, silent = true })
