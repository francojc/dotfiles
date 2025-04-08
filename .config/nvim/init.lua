-- Paq --------------------------------------------
require("paq")({
	"savq/paq-nvim", -- Paq manages itself 
	"neovim/nvim-lspconfig", -- LSP 
	"stevearc/conform.nvim", -- Formatter
	"stevearc/oil.nvim", -- File explorer
	"ibhagwan/fzf-lua", -- FZF
	"github/copilot.vim", -- Copilot
	"folke/which-key.nvim", -- Keymaps
	"vague2k/vague.nvim", -- Colorscheme
	"nvim-treesitter/nvim-treesitter", -- Treesitter
	"echasnovski/mini.pairs", -- Pairs 
	"echasnovski/mini.statusline", -- Statusline
	"echasnovski/mini.indentscope", -- Indent guides
	"echasnovski/mini.icons", -- Icons
})

--- Options ----------------------------------------
-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
-- Gutter
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.showmode = false 
-- Wrap 
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
-- Splits 
vim.opt.splitbelow = true 
vim.opt.splitright = true
-- Search 
vim.opt.ignorecase = true 
vim.opt.smartcase = true 
vim.opt.incsearch = true 
vim.opt.hlsearch = false 

-- Clipboard 
vim.opt.clipboard = "unnamedplus"
-- Undo 
vim.opt.undofile = true 
vim.opt.undodir = os.getenv("HOME") .. "/.cache/nvim/undodir"
-- Backup 
vim.opt.backup = false
vim.opt.swapfile = false

--- LSPs ----------------------------------------
local lspconfig = require("lspconfig")
lspconfig.air.setup{} 
lspconfig.marksman.setup{}
require("conform").setup({
	formatters_by_ft = {
		r = { "air" },
		quarto = { "air", "marksman" },
		markdown = { "marksman" },
	},
	format_after_save = {},
})

--- Keymaps ----------------------------------------
--- General -----
vim.keymap.set("i", "jj", "<Esc>", { desc = "Insert mode: jj to escape" })
vim.keymap.set("n", "<C-s>", "<Cmd>w<Cr>", { desc = "Save file" })
vim.keymap.set("n", "<C-a>", "<Cmd>wa<Cr>", { desc = "Save all files" })
vim.keymap.set("n", "<leader>x", "<Cmd>quit<Cr>", { desc = "Quit" })
--- AI -----
vim.keymap.set("i", "<C-d>", "<Plug>(copilot-accept-word)", { desc = "Copilot: Accept word" })
vim.keymap.set("i", "<C-f>", "<Plug>(copilot-accept-line)", { desc = "Copilot: Accept line" })
vim.keymap.set("i", "<C-n>", "<Plug>(copilot-next)", { desc = "Copilot: Next suggestion" })
vim.keymap.set("i", "<C-p>", "<Plug>(copilot-previous)", { desc = "Copilot: Previous suggestion" })
--- FZF -----
vim.keymap.set("n", "<leader>ff", "<Cmd>FzfLua files<Cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<Cmd>FzfLua live_grep<Cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fr", "<Cmd>FzfLua oldfiles<Cr>", { desc = "Recent files" })
-- Oil -----
vim.keymap.set("n", "-", "<Cmd>Oil --float<Cr>", { desc = "Open parent directory" })
--- Plugins ----------------------------------------
-- Colorscheme ----- 
require("vague").setup({})
vim.cmd("colorscheme vague")
-- FZF -----
require("fzf-lua").setup({ })
-- Mini -----
require("mini.pairs").setup({}) 
require("mini.statusline").setup({})
require("mini.indentscope").setup({})
-- Oil ----- 
-- setup oil 
require("oil").setup({
	columns = {
		"icon",
		"size",
	},
	skip_confirm_for_simple_edits = true,
	view_options = {
		show_hidden = true,
	},
	keymaps = {
		["<Esc>"] = { "actions.close", mode = "n" },
	},
})

-- Treesitter -----
-- register quarto as markdown
vim.treesitter.language.register("markdown", "quarto") 

-- setup treesitter 
require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},
})

-- WhichKey -----
-- setup
require("which-key").setup({
	preset = "helix",
	icons = {
		group = " ",
	},
})
-- add keymap groups
local wk = require("which-key")
wk.add({
	{ "<leader>f", group = "Find", icon = "" },
	{ "<leader>b", group = "Buffer", icon = "" },
	{ "<leader>g", group = "Git", icon = "" },
	{ "<leader>l", group = "LSP", icon = "" },
	{ "<leader>t", group = "Terminal", icon = "" },
	{ "<leader>w", proxy = "<C-w>", group = "Windows", icon = "" },
	{ "<leader>h", group = "Help", icon = "" },
})

-- Autocommands ----------------------------------------
-- Highlight on yank 
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
})

