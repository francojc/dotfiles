---| Neovim: basic configuration |---------------------------------------
---|
---| Package Manager ----------------------------------------------------

-- Bootstrap paq-nvim installation
local function bootstrap_paq()
	local path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
	if vim.fn.empty(vim.fn.glob(path)) > 0 then
		vim.fn.system({
			"git",
			"clone",
			"--depth=1",
			"https://github.com/savq/paq-nvim.git",
			path,
		})
		vim.cmd("packadd paq-nvim")
	end
end

bootstrap_paq()

-- Plugin setup
require("paq")({
	"christoomey/vim-tmux-navigator",
	"folke/flash.nvim",
	"github/copilot.vim",
	"nvim-treesitter/nvim-treesitter",
	"nvim-lua/plenary.nvim",
	"savq/paq-nvim",
	"stevearc/conform.nvim",
	"ibhagwan/fzf-lua",
	"mikavilpas/yazi.nvim",
	"metalelf0/black-metal-theme-neovim",
	"webhooked/kanso.nvim",
	"rebelot/kanagawa.nvim",
})

---| Options ------------------------------------------------------
local a = vim.api
local g = vim.g
local opt = vim.opt
local cmd = vim.cmd

-- Appearance and UI
require("black-metal").setup()
cmd.colorscheme("kanagawa")

opt.termguicolors = true
opt.background = "dark"
opt.winborder = "rounded"
opt.showmode = false
opt.cmdheight = 0
opt.laststatus = 2
-- Search count function
function _G.searchcount()
	local result = vim.fn.searchcount({ maxcount = 0 })
	if result.total > 0 then
		return string.format("[%d/%d]", result.current, result.total)
	end
	return ""
end

opt.statusline = "%#StatusLine#%f %m%r%h%w %{v:lua.searchcount()} %=%-14.(%l,%c%V%) %P"

-- Line numbers and cursor
opt.relativenumber = true
opt.number = true
opt.cursorline = true
opt.cursorlineopt = "number"
opt.signcolumn = "yes"

-- Indentation and formatting
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true

-- Text wrapping and display
opt.wrap = true
opt.linebreak = true
opt.showbreak = "↪ "
opt.list = false

-- Scrolling and splits
opt.scrolloff = 3
opt.sidescrolloff = 5
opt.splitbelow = true
opt.splitright = true

-- Search behavior
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Spell checking
opt.spell = false
opt.spelllang = { "en_us" }
opt.spellfile = vim.fn.expand("~/.spell/en.utf-8.add")

-- File handling and backups
opt.backup = false
opt.swapfile = false
opt.undodir = vim.fn.expand("~/.vim/undodir")
opt.undofile = true
opt.autoread = true

-- Completion and navigation
opt.completeopt = "menu,menuone,noselect"
opt.path:append("**")
opt.clipboard:append("unnamedplus")

-- Tabs and formatting
opt.showtabline = 0
opt.formatexpr = "v:lua.require('conform').formatexpr()"

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

---| Autocmds ------------------------------------------------------

a.nvim_create_augroup("personal", { clear = true })
-- Highlight on yank
a.nvim_create_autocmd("TextYankPost", {
	group = "personal",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank()
	end,
})

---| Keymaps -------------------------------------------------------
-- Leader key -----
g.mapleader = " "
g.maplocalleader = " "

-- map() function -----
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	if type(mode) == "table" then
		for _, m in ipairs(mode) do
			vim.api.nvim_set_keymap(m, lhs, rhs, options)
		end
	else
		vim.api.nvim_set_keymap(mode, lhs, rhs, options)
	end
end

---| Vim
map("i", "jj", "<Esc>", { desc = "Exit insert mode with jj" })
map("n", "<C-s>", "<Cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>x", "<Cmd>qa<CR>", { desc = "Quit" })
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "gl", "$", { desc = "Go to end of line" })
map("n", "gh", "^", { desc = "Go to start of line" })

-- Autocompletion ------------------------
g.copilot_settings = { selectedCompletionModel = "gpt-4o-copilot" }
g.copilot_no_tab_map = true

map("i", "<Tab>", "<Plug>(copilot-accept-word)", { desc = "Accept word" })
map("i", "<C-d>", "<Plug>(copilot-accept-line)", { desc = "Accept line" })
map("i", "<C-f>", "copilot#Accept('\\<Cr>')", { expr = true, replace_keycodes = false, desc = "Accept suggestion" })
map("i", "<C-n>", "<Plug>(copilot-next)", { desc = "Next suggestion" })
map("i", "<C-p>", "<Plug>(copilot-previous)", { desc = "Previous suggestion" })
map("i", "<C-e>", "<Plug>(copilot-dismiss)", { desc = "Dismiss suggestion" })

-- Editing --------------------------------
-- Paste without overwriting register
map("v", "p", '"_dP', { desc = "Paste without overwriting register" })

-- Explore -------------------------------
map("n", "<leader>ey", "<Cmd>Yazi<Cr>", { desc = "Yazi" })
map("n", "<leader>ec", "<Cmd>Yazi cwd<Cr>", { desc = "Yazi cwd" })

-- Find ---------------------------------
map("n", "<leader>fb", "<Cmd>FzfLua buffers<Cr>", { desc = "Find buffers" })
map("n", "<leader>fc", "<Cmd>FzfLua resume<Cr>", { desc = "Resume fzf" })
map("n", "<leader>ff", "<Cmd>FzfLua files<Cr>", { desc = "Find files" })
map("n", "<leader>fg", "<Cmd>FzfLua live_grep resume=true<Cr>", { desc = "Live grep" })
map("n", "<leader>fn", "<Cmd>enew<Cr>", { desc = "New file" })
map("n", "<leader>fr", "<Cmd>FzfLua oldfiles<Cr>", { desc = "Recent files" })

-- Movement -----------------------------
-- Flash search
map({ "n", "x", "o" }, "<leader>sf", "<Cmd>lua require('flash').jump()<Cr>", { desc = "Flash" })
map({ "n", "x", "o" }, "<leader>sF", "<Cmd>lua require('flash').treesitter()<Cr>", { desc = "Flash treesitter" })
-- Go to
-- Beginning of line
map({ "n", "v" }, "gh", "^", { desc = "Go to beginning of line" })
-- End of line
map({ "n", "v" }, "gl", "$", { desc = "Go to end of line" })
map({ "n", "v" }, "go", "o<Esc>", { desc = "Add line below current line" })
-- Line up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
-- Next visual line
map("n", "j", "gj", { desc = "Next visual line" })
map("n", "k", "gk", { desc = "Previous visual line" })
-- Window-centered movement
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Previous search result" })

---| Setups ------------------------------------------------------

--- Conform
require("conform").setup({
	default_format_ops = {
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		bash = { "shfmt" },
		json = { "jq" },
		jsonl = { "jq" },
		lua = { "stylua" },
		markdown = { "mdformat" },
		nix = { "alejandra" },
		python = { "ruff", lsp_format = "fallback" },
		r = { "air" },
		["*"] = { "trim_whitespace" },
	},
	format_on_save = function()
		-- Do not format markdown/quarto files on save
		local ft = vim.bo.filetype
		if ft == "markdown" or ft == "quarto" then
			return false
		end
		return {
			timeout_ms = 500,
			lsp_format = "fallback",
		}
	end,
	notify_on_error = false,
})

--- Treesitter -----------------------------------
require("nvim-treesitter.configs").setup({
	auto_install = true, -- Key for the `paq` approach to get parsers
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<Enter>",
			node_incremental = "<Enter>",
			scope_incremental = false,
			node_decremental = "<Backspace>",
		},
	},
	indent = { enable = false },
})
