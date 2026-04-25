---| Plugin Management with vim.pack ---------------------------------
-- Declares all plugins. Configuration and lazy-loading logic lives
-- in plugins-config.lua.
--
-- eager_plugins → pack/core/start/ (loaded immediately at startup)
-- opt_plugins   → pack/core/opt/   (loaded on demand via :packadd)

--===========================================================================
--| EAGER PLUGINS
--===========================================================================

local eager_plugins = {
	-- Themes (needed early for colorscheme)
	{ src = "https://github.com/thenewvu/vim-colors-arthur" },
	{ src = "https://github.com/wolloda/vim-autumn" },
	{ src = "https://github.com/metalelf0/black-metal-theme-neovim" },
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	{ src = "https://github.com/ellisonleao/gruvbox.nvim" },
	{ src = "https://github.com/EdenEast/nightfox.nvim" },
	{ src = "https://github.com/navarasu/onedark.nvim" },
	{ src = "https://github.com/folke/tokyonight.nvim" },
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/Mofiqul/vscode.nvim" },
	{ src = "https://github.com/ayu-theme/ayu-vim" },
	{ src = "https://github.com/webhooked/kanso.nvim" },

	-- Core (must be available at startup)
	{ src = "https://github.com/saghen/blink.cmp", 
      version = "v1", -- branch
    },
	{ src = "https://github.com/brenoprata10/nvim-highlight-colors" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	{ src = "https://github.com/echasnovski/mini.icons" },
	{ src = "https://github.com/echasnovski/mini.surround" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/ggml-org/llama.vim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
	{ src = "https://github.com/moyiz/blink-emoji.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/neovim-treesitter/treesitter-parser-registry" },
	{
		src = "https://github.com/neovim-treesitter/nvim-treesitter",
		version = "main",
		dependencies = { "neovim-treesitter/treesitter-parser-registry" },
	},
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/stevearc/conform.nvim" },
}

vim.pack.add(eager_plugins, { load = true, confirm = false })

--===========================================================================
--| OPT PLUGINS (lazy-loaded via :packadd in plugins-config.lua)
--===========================================================================

local opt_plugins = {
	{ src = "https://github.com/3rd/image.nvim" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/folke/todo-comments.nvim" },
	{ src = "https://github.com/hakonharnes/img-clip.nvim" },
	{ src = "https://github.com/hat0uma/csvview.nvim" },
	{ src = "https://github.com/jmbuhr/otter.nvim" },
	{ src = "https://github.com/jpalardy/vim-slime" },
	{ src = "https://github.com/sindrets/diffview.nvim" },
	{ src = "https://github.com/krissen/snacks-bibtex.nvim" },
	{ src = "https://github.com/nametake/golangci-lint-langserver" },
	{ src = "https://github.com/obsidian-nvim/obsidian.nvim" },
	{ src = "https://github.com/quarto-dev/quarto-nvim" },
	{ src = "https://github.com/stevearc/aerial.nvim" },
	{ src = "https://github.com/stevearc/quicker.nvim" },
}

vim.pack.add(opt_plugins, { load = false, confirm = false })
