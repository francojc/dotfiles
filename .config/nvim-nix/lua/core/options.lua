-- Neovim 0.11.x Options
-- Compatible with stable Neovim (no 0.12+ features)

local opt = vim.opt
local g = vim.g

-- Globals
g.mapleader = ' '
g.maplocalleader = ' '
g.copilot_no_tab_map = true
g.slime_target = 'tmux'

-- Session options
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- Autowrite
opt.autowrite = true
opt.autowriteall = true

-- Clipboard
opt.clipboard:append('unnamedplus')

-- Completion (0.11-compatible, no pumborder/pummaxwidth)
opt.completeopt = 'menu,menuone,noselect'
opt.path:append('**')

-- Window
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 1
opt.sidescrolloff = 5
opt.wrap = true

-- Gutter
opt.relativenumber = true
opt.number = true
opt.signcolumn = 'yes'
opt.cursorline = true
opt.cursorlineopt = 'number'

-- Tabs
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.showtabline = 0

-- Indentation
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true
opt.linebreak = true
opt.showbreak = '↪ '

-- Display
opt.list = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Spelling
opt.spell = false
opt.spelllang = { 'en_us' }
opt.spellfile = vim.fn.expand('~/.spell/en.utf-8.add')

-- Swap/backup/undo
opt.backup = false
opt.swapfile = false
opt.undodir = vim.fn.expand('~/.vim/undodir')
opt.undofile = true

-- Colors
opt.termguicolors = true
opt.background = 'dark'

-- Misc
opt.showmode = false
opt.cmdheight = 0
opt.autoread = true
opt.foldmethod = 'indent'
opt.foldlevel = 99
opt.laststatus = 2

-- Formatexpr for conform
opt.formatexpr = "v:lua.require'conform'.formatexpr()"
