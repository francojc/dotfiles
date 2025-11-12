---| Plugin Management with vim.pack ---------------------------------
-- This file declares all plugins using Neovim 0.12+ native vim.pack
-- Plugins are installed to pack/core/start (eager) or pack/core/opt (lazy)

-- Eager-loaded plugins (load immediately at startup)
-- These provide core functionality needed at startup
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

	-- Core functionality plugins (eager-loaded)
	{ src = "https://github.com/Saghen/blink.cmp" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	{ src = "https://github.com/echasnovski/mini.icons" },
	{ src = "https://github.com/echasnovski/mini.pairs" },
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/echasnovski/mini.surround" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/github/copilot.vim" },
	{ src = "https://github.com/jmbuhr/cmp-pandoc-references" },
	{ src = "https://github.com/jpalardy/vim-slime" },
	{ src = "https://github.com/moyiz/blink-emoji.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/abecodes/tabout.nvim" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/jmbuhr/otter.nvim" },
	{ src = "https://github.com/obsidian-nvim/obsidian.nvim" },
}

-- Lazy-loaded plugins (optional - loaded on demand via autocommands/commands)
-- These plugins are installed to pack/core/opt/ and loaded with vim.cmd.packadd()
local lazy_plugins = {
	{ src = "https://github.com/3rd/image.nvim" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/folke/todo-comments.nvim" },
	{ src = "https://github.com/hakonharnes/img-clip.nvim" },
	{ src = "https://github.com/hat0uma/csvview.nvim" },
	{ src = "https://github.com/kdheepak/lazygit.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
	{ src = "https://github.com/brenoprata10/nvim-highlight-colors" },
	{ src = "https://github.com/quarto-dev/quarto-nvim" },
	{ src = "https://github.com/stevearc/aerial.nvim" },
}

-- Install and load eager plugins immediately
vim.pack.add(eager_plugins, { load = true, confirm = false })

-- Install lazy plugins as optional (to pack/core/opt/)
-- They will be loaded on-demand via vim.cmd.packadd() in autocommands
vim.pack.add(lazy_plugins, { load = false, confirm = false })
