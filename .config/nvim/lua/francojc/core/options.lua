-- add tree-like file explorer
vim.cmd("let g:netrw_liststyle = 3")
 
-- add line numbers
local opt = vim.opt
opt.relativenumber = true -- add numbers relative to current position
opt.number = true -- add current line number

-- tabs and indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case in searches
opt.smartcase = true -- with mixed-case search, case-sensitive enabled

opt.cursorline = true -- highlight current line

-- turn on termguicolors
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent

-- clipboard
opt.clipboard:append("unnamedplus") --use system clipboard

-- split windows
opt.splitright = true
opt.splitbelow = true

-- turn off swapfile
opt.swapfile = false
