---| Options ------------------------------------------------------
--- Locals -----
local a = vim.api
local opt = vim.opt

-- Globals -----
-- Record start time for startup duration
_G.nvim_config_start_time = vim.loop.hrtime()

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Locals -----
-- Clipboard
opt.clipboard:append("unnamedplus") --- Use system clipboard
-- Completions
opt.completeopt = "menu,menuone,noselect,nearest" -- Completion options (nearest = distance-based sorting in 0.12+)
opt.path:append("**") -- Search subdirectories
-- Neovim 0.12+ native completion UI enhancements
opt.pumborder = "rounded" -- Popup menu border (0.12+)
opt.pummaxwidth = 60 -- Maximum width for popup menu (0.12+)
-- Window
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 3
opt.sidescrolloff = 5
opt.wrap = true
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
opt.showtabline = 0
-- Indentation
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true
opt.linebreak = true
opt.showbreak = "↪ "
-- Display chars
opt.list = false
-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
-- Spelling
opt.spell = false
opt.spelllang = { "en_us" }
opt.spellfile = vim.fn.expand("~/.spell/en.utf-8.add")
-- Swap/backup/undo
opt.backup = false
opt.swapfile = false
opt.undodir = vim.fn.expand("~/.vim/undodir")
opt.undofile = true
-- Colors
opt.termguicolors = true
opt.background = "dark"
-- Misc
opt.winborder = "rounded"
opt.showmode = false
opt.cmdheight = 0
opt.formatexpr = "v:lua.require('conform').formatexpr()"
opt.autoread = true -- auto read files when changed outside of Neovim
opt.foldmethod = "indent"
opt.foldlevel = 99 -- start with all folds open
opt.laststatus = 2 -- show statusline always

-- Statusline (native, leveraging Neovim 0.12+ vim.diagnostic.status())
vim.o.statusline = table.concat({
	"%#StatusLineModeNormal#",
	" %{v:lua.Get_mode_name()} ", -- Mode (full name)
	"%#StatusLineModified#",
	"%{&modified?' [+]':''}", -- Modified indicator
	"%#StatusLine#",
	"%{&readonly?' []':''} ", -- Readonly indicator
	"%#StatusLineGit#",
	"%{v:lua.Get_git_branch()}", -- Git branch
	"%#StatusLineFilename#",
	" %f ", -- Filename with path
	"%#StatusLine#",
	"%=", -- Right align
	"%{v:lua.vim.diagnostic.status()} ", -- Diagnostic count (0.12+ native)
	"%#StatusLineModeNormal#",
	" %Y ", -- File type
	"%#StatusLine#",
	" %3l:%-2c ", -- Line:Column
	"%#StatusLineModeNormal#",
	" %p%% ", -- Percentage through file
	"%#StatusLine#",
}, "")

-- Diagnostics
vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	virtual_text = {
		severity = {
			min = vim.diagnostic.severity.INFO,
			max = vim.diagnostic.severity.WARN,
		},
	},
	virtual_lines = {
		current_line = true,
		severity = {
			min = vim.diagnostic.severity.ERROR,
			max = vim.diagnostic.severity.ERROR,
		},
	},
})
