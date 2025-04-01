-- Autocommands -------------------------------------------------

a = vim.api

-- Create an autocommand group
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


-- Keymaps ------------------------------------------------------

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


-- Files -------
-- Neotree

map("n", "<leader>ft", "<Cmd>Neotree<Cr>")

-- Options ------------------------------------------------------

opt = vim.opt

-- Clipboard
opt.clipboard = "unnamedplus"

-- Completions
opt.completeopt = "menu,preview,noselect"

-- Window
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 3
opt.sidescrolloff = 5
opt.wrap = false

-- Gutter
opt.relativenumber = true
opt.number = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.cursorlineopt = "number"

-- Tabs
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.showtabline = 2

-- Indentation
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true
opt.linebreak = true
opt.showbreak = "↪ "

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = false

-- Swap/backup/undo
opt.backup = false
opt.swapfile = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

-- Colors
opt.termguicolors = true
opt.background = "dark"

-- Misc
-- opt.mouse = "a"

-- Plugins ------------------------------------------------------
-- Startup time

vim.cmd("colorscheme gruvbox")

-- Lazy load plugins

-- require('config.plugins')


