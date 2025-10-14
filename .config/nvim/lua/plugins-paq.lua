---| Paq: plugins -------------------------------------------------
require("paq")({
	-- Lazy-loading support
	"nvim-neorocks/lz.n", -- Lazy-loading plugin loader

	-- themes (eager-load for colorscheme)
	"thenewvu/vim-colors-arthur", -- Arthur theme
	"wolloda/vim-autumn", -- Autumn theme
	"metalelf0/black-metal-theme-neovim", -- Black Metal theme
	"ellisonleao/gruvbox.nvim", -- Gruvbox theme
	"EdenEast/nightfox.nvim", -- theme
	"navarasu/onedark.nvim", -- One Dark theme
	"vague2k/vague.nvim", -- Vague theme

	-- Eager-loaded plugins (core functionality)
	"Saghen/blink.cmp", -- Blink completion
	"akinsho/bufferline.nvim", -- Bufferline
	"christoomey/vim-tmux-navigator", -- nav through vim/tmux
	"echasnovski/mini.icons", -- Icons
	"echasnovski/mini.indentscope", -- Indent guides
	"echasnovski/mini.pairs", -- Pairs
	"echasnovski/mini.surround", -- Surround
	"folke/flash.nvim", -- Flash jump
	"folke/sidekick.nvim", -- AI sidekick (NES + CLI)
	"folke/snacks.nvim", -- Input and terminal utils
	"folke/which-key.nvim", -- Keymaps popup
	"github/copilot.vim", -- Copilot
	"goolord/alpha-nvim", -- Alpha dashboard
	"ibhagwan/fzf-lua", -- FZF fuzzy finder
	"j-hui/fidget.nvim", -- LSP progress indicator
	"jmbuhr/cmp-pandoc-references", -- Pandoc references
	"jpalardy/vim-slime", -- Slime integration
	"lilydjwg/colorizer", -- Colorizer
	"moyiz/blink-emoji.nvim", -- Blink emoji
	"nvim-lua/plenary.nvim", -- Plenary for Lua functions
	"nvim-lualine/lualine.nvim", -- Statusline
	"nvim-tree/nvim-web-devicons", -- Web devicons
	"nvim-treesitter/nvim-treesitter", -- Treesitter
	"L3MON4D3/LuaSnip", -- Snippet engine
	"rafamadriz/friendly-snippets", -- Snippets
	"rcarriga/nvim-notify", -- Notifications
	"savq/paq-nvim", -- Paq manages itself
	"stevearc/conform.nvim", -- Formatter

	-- Lazy-loaded plugins (marked with opt = true)
	-- These will be loaded by lz.n based on triggers (see ./plugins/)
	{ "3rd/image.nvim", opt = true }, -- Image support (lazy: ft markdown/quarto)
	{ "MeanderingProgrammer/render-markdown.nvim", opt = true }, -- Render-Markdown (lazy: ft markdown/quarto)
	{ "akinsho/toggleterm.nvim", opt = true }, -- Toggle terminal (lazy: cmd)
	{ "folke/todo-comments.nvim", opt = true }, -- Todo comments (lazy: cmd)
	{ "hakonharnes/img-clip.nvim", opt = true }, -- Image pasting (lazy: ft markdown)
	{ "hat0uma/csvview.nvim", opt = true }, -- CSV viewer (lazy: ft csv)
	"jmbuhr/otter.nvim", -- Otter for Quarto (eager-load)
	{ "kdheepak/lazygit.nvim", opt = true }, -- Lazygit integration (lazy: cmd)
	{ "lewis6991/gitsigns.nvim", opt = true }, -- Git signs (lazy: event)
	{ "mikavilpas/yazi.nvim", opt = true }, -- Yazi file manager (lazy: cmd)
	{ "obsidian-nvim/obsidian.nvim", opt = true }, -- Obsidian integration (lazy: ft markdown)
	{ "quarto-dev/quarto-nvim", opt = true }, -- Quarto integration (lazy: ft quarto)
	{ "stevearc/aerial.nvim", opt = true }, -- Code outline (lazy: cmd)
})
