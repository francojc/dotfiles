-- Plugin declarations using paq-nvim
-- For Neovim 0.11.x (replaces vim-plug)

local fn = vim.fn

-- Auto-install paq-nvim
local paq_path = fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
if fn.empty(fn.glob(paq_path)) > 0 then
	print("Installing paq-nvim...")
	fn.system({
		"git",
		"clone",
		"--depth=1",
		"https://github.com/savq/paq-nvim.git",
		paq_path,
	})
	vim.cmd("packadd paq-nvim")
end

require("paq")({
	"savq/paq-nvim", -- Let paq manage itself

	-- Themes
	"ellisonleao/gruvbox.nvim",
	"thenewvu/vim-colors-arthur",
	"metalelf0/black-metal-theme-neovim",
	"EdenEast/nightfox.nvim",
	"navarasu/onedark.nvim",
	"folke/tokyonight.nvim",
	"vague2k/vague.nvim",
	"Mofiqul/vscode.nvim",
	"ayu-theme/ayu-vim",

	-- Core functionality
	"nvim-lua/plenary.nvim",
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	-- nvim-lspconfig removed: using native vim.lsp.config (0.11+)

	-- Completion
	"Saghen/blink.cmp",
	"L3MON4D3/LuaSnip",
	"rafamadriz/friendly-snippets",

	-- UI/UX
	"folke/which-key.nvim",
	"folke/snacks.nvim",
	"folke/todo-comments.nvim",
	"lewis6991/gitsigns.nvim",
	"echasnovski/mini.surround",
	"echasnovski/mini.icons",
	"stevearc/aerial.nvim",
	"brenoprata10/nvim-highlight-colors",

	-- Editing
	"stevearc/conform.nvim",
	"abecodes/tabout.nvim",
	"christoomey/vim-tmux-navigator",

	-- Git
	"kdheepak/lazygit.nvim",

	-- File management
	"mikavilpas/yazi.nvim",

	-- Markdown/Notes
	"MeanderingProgrammer/render-markdown.nvim",
	"obsidian-nvim/obsidian.nvim",
	"quarto-dev/quarto-nvim",
	"jmbuhr/otter.nvim",
	"hakonharnes/img-clip.nvim",

	-- Languages
	"chomosuke/typst-preview.nvim",
	"hat0uma/csvview.nvim",
	"moyiz/blink-emoji.nvim",
	"krissen/snacks-bibtex.nvim",

	-- AI
	"github/copilot.vim",
	"CopilotC-Nvim/CopilotChat.nvim",

	-- Slime/REPL
	"jpalardy/vim-slime",

	-- Quickfix
	"stevearc/quicker.nvim",
})

-- Helper message for first run
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local paq = require("paq")
		-- Check if any plugins need installing
		local missing = false
		for _, plugin in pairs(paq._packages or {}) do
			if plugin.status == "to_install" then
				missing = true
				break
			end
		end
		if missing then
			vim.notify("Run :PaqInstall to install plugins", vim.log.levels.INFO)
		end
	end,
	once = true,
})
