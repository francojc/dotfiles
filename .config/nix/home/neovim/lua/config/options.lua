-- Options ---------------------------------------
opt = vim.opt

-- Clipboard 
opt.clipboard = "unnamedplus" 

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

-- Misc
opt.mouse = "a"
opt.mousemove = true
