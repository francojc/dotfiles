-- Paq --------------------------------------------
require("paq")({
	"savq/paq-nvim", -- 
	"neovim/nvim-lspconfig", -- 
	"stevearc/conform.nvim",
	"ibhagwan/fzf-lua",
	"github/copilot.vim",
	"folke/which-key.nvim",
	"vague2k/vague.nvim",
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

-- Wrap 
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true


--- LSPs ----------------------------------------
local lspconfig = require("lspconfig")

lspconfig.air.setup{} 
lspconfig.marksman.setup{}

--- Plugins ---------------------------------------- 

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
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", "<C-s>", "<Cmd>w<Cr>")
vim.keymap.set("n", "<C-a>", "<Cmd>wa<Cr>")
vim.keymap.set("n", "<leader>x", "<Cmd>quit<Cr>")

--- AI -----
vim.keymap.set("i", "<C-d>", "<Plug>(copilot-accept-word)")
vim.keymap.set("i", "<C-f>", "<Plug>(copilot-accept-line)")
vim.keymap.set("i", "<C-n>", "<Plug>(copilot-next)")
vim.keymap.set("i", "<C-p>", "<Plug>(copilot-previous)")

--- FZF -----
vim.keymap.set("n", "<leader>ff", "<Cmd>FzfLua files<Cr>")
vim.keymap.set("n", "<leader>fg", "<Cmd>FzfLua live_grep<Cr>")
vim.keymap.set("n", "<leader>fr", "<Cmd>FzfLua oldfiles cwd=./<Cr>")

-- WhichKey -----
require("which-key").setup({})

-- Colorscheme ----- 
require("vague").setup({})

vim.cmd("colorscheme vague")
