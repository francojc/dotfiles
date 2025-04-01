-- Keymaps ----------------------------------------

g = vim.g

-- Leader key
g.mapleader = " "
g.maplocalleader = " "

-- Keymaps ----------------------------------------

function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Convenience ----------------- 
-- jj to escape insert mode
map("i", "jj", "<Esc>")

-- Hide highlights 
map("n", "<Esc>", "<Esc><Cmd>nohlsearch<Cr>")

-- Save file
map("n", "<C>s", ":w<Cr>")
map("n", "<C-a>", ":wa<Cr>")

-- Close buffer
map("n", "<C-q>", ":bd<Cr>") 

-- Quit 
map("n", "<leader>x", ":qa<Cr>")

--- Window management -----------
-- Move between windows
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Resize windows
map("n", "<C-Up>", ":resize -2<Cr>")
map("n", "<C-Down>", ":resize +2<Cr>")
map("n", "<C-Left>", ":vertical resize -2<Cr>")
map("n", "<C-Right>", ":vertical resize +2<Cr>")


