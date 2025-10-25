-- =============================================================================
-- Neovim 0.12 Minimalist Configuration
-- =============================================================================

-- =============================================================================
-- 1. CORE EDITOR SETTINGS
-- =============================================================================

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Record start time for startup duration
_G.nvim_config_start_time = vim.loop.hrtime()

-- Session options
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Line numbers and gutter
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "

-- Language-specific indentation
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
	end,
})

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.path:append("**")

-- UI and display
vim.opt.termguicolors = true
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 5
vim.opt.wrap = true
vim.opt.colorcolumn = "80"
vim.opt.showmode = false
vim.opt.cmdheight = 0
vim.opt.laststatus = 2
vim.opt.showtabline = 2
vim.opt.list = false

-- Window and splits
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.winborder = "rounded"

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Undo and backup
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.backup = false
vim.opt.swapfile = false

-- Folding
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99

-- Spelling
vim.opt.spell = false
vim.opt.spelllang = { "en_us" }
vim.opt.spellfile = vim.fn.expand("~/.spell/en.utf-8.add")

-- Performance
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.autoread = true

-- Misc
vim.opt.mouse = "a"
vim.opt.background = "dark"

-- =============================================================================
-- 2. NEW NVIM 0.12 FEATURES
-- =============================================================================

-- Built-in auto-completion (NEW in 0.12!)
vim.opt.autocomplete = true

-- Fuzzy completion collection (NEW in 0.12!)
-- Enable fuzzy matching for keyword completion
vim.opt.completefuzzycollect = "keyword"

-- Completion options with distance-based sorting (NEW in 0.12!)
vim.opt.completeopt = "menu,menuone,noselect,nearest"

-- Popup menu border (NEW in 0.12!)
vim.opt.pumborder = "single"

-- Maximum popup menu width (NEW in 0.12!)
vim.opt.pummaxwidth = 60

-- =============================================================================
-- 3. PLUGIN MANAGEMENT WITH VIM.PACK (NEW IN 0.12!)
-- =============================================================================

-- Helper function to install plugins using vim.pack (eager-loaded)
local function install_plugin(url, name)
	local install_path = vim.fn.stdpath("data") .. "/site/pack/plugins/start/" .. name

	if vim.fn.isdirectory(install_path) == 0 then
		print("Installing " .. name .. "...")
		vim.fn.system({
			"git",
			"clone",
			"--depth=1",
			url,
			install_path,
		})
		vim.cmd("packloadall")
		return true
	end
	return false
end

-- Helper function to install opt plugins (lazy-loaded)
local function install_opt_plugin(url, name)
	local install_path = vim.fn.stdpath("data") .. "/site/pack/plugins/opt/" .. name

	if vim.fn.isdirectory(install_path) == 0 then
		print("Installing " .. name .. " (lazy)...")
		vim.fn.system({
			"git",
			"clone",
			"--depth=1",
			url,
			install_path,
		})
		return true
	end
	return false
end

-- Install plugins
local plugins_installed = false

-- Core plugins (already installed)
plugins_installed = install_plugin("https://github.com/folke/tokyonight.nvim", "tokyonight.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/nvim-lua/plenary.nvim", "plenary.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/nvim-treesitter/nvim-treesitter", "nvim-treesitter")
	or plugins_installed
plugins_installed = install_plugin("https://github.com/ibhagwan/fzf-lua", "fzf-lua") or plugins_installed
plugins_installed = install_plugin("https://github.com/mikavilpas/yazi.nvim", "yazi.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/lewis6991/gitsigns.nvim", "gitsigns.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/nvim-lualine/lualine.nvim", "lualine.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/L3MON4D3/LuaSnip", "LuaSnip") or plugins_installed
plugins_installed = install_plugin("https://github.com/rafamadriz/friendly-snippets", "friendly-snippets")
	or plugins_installed

-- Phase 3: Colorschemes (eager-loaded for theme switching)
plugins_installed = install_plugin("https://github.com/thenewvu/vim-colors-arthur", "vim-colors-arthur")
	or plugins_installed
plugins_installed = install_plugin("https://github.com/wolloda/vim-autumn", "vim-autumn") or plugins_installed
plugins_installed = install_plugin("https://github.com/metalelf0/black-metal-theme-neovim", "black-metal-theme-neovim")
	or plugins_installed
plugins_installed = install_plugin("https://github.com/ellisonleao/gruvbox.nvim", "gruvbox.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/EdenEast/nightfox.nvim", "nightfox.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/navarasu/onedark.nvim", "onedark.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/vague2k/vague.nvim", "vague.nvim") or plugins_installed

-- Phase 4: Essential Plugins (eager-loaded)
plugins_installed = install_plugin("https://github.com/stevearc/conform.nvim", "conform.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/echasnovski/mini.nvim", "mini.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/folke/flash.nvim", "flash.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/github/copilot.vim", "copilot.vim") or plugins_installed
plugins_installed = install_plugin("https://github.com/folke/which-key.nvim", "which-key.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/christoomey/vim-tmux-navigator", "vim-tmux-navigator")
	or plugins_installed
plugins_installed = install_plugin("https://github.com/nvim-tree/nvim-web-devicons", "nvim-web-devicons")
	or plugins_installed

-- Phase 4: Lazy-Loaded Plugins (optional plugins loaded on demand)

-- Academic writing plugins
plugins_installed = install_opt_plugin("https://github.com/quarto-dev/quarto-nvim", "quarto-nvim") or plugins_installed
plugins_installed = install_opt_plugin("https://github.com/jmbuhr/otter.nvim", "otter.nvim") or plugins_installed
plugins_installed = install_opt_plugin("https://github.com/epwalsh/obsidian.nvim", "obsidian.nvim") or plugins_installed
plugins_installed = install_opt_plugin(
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	"render-markdown.nvim"
) or plugins_installed
plugins_installed = install_opt_plugin("https://github.com/preservim/vim-markdown", "vim-markdown") or plugins_installed
plugins_installed = install_opt_plugin("https://github.com/jmbuhr/cmp-pandoc-references", "cmp-pandoc-references")
	or plugins_installed

-- Utility plugins
plugins_installed = install_opt_plugin("https://github.com/kdheepak/lazygit.nvim", "lazygit.nvim") or plugins_installed
plugins_installed = install_opt_plugin("https://github.com/NvChad/nvim-colorizer.lua", "nvim-colorizer.lua")
	or plugins_installed

-- Reload config if plugins were just installed
if plugins_installed then
	print("Plugins installed. Please restart Neovim.")
end

-- =============================================================================
-- 4. THEME CONFIGURATION
-- =============================================================================

-- Theme selection and configuration
-- Change the colorscheme value to switch themes:
-- Options: "tokyonight", "arthur", "autumn", "black-metal", "gruvbox",
--          "nightfox", "onedark", "vague"
local theme_config = {
	colorscheme = "tokyonight",
	colors = {
		bg = "#212e3f",
		fg = "#cdcecf",
		yellow = "#dbc074",
	},
}

-- =============================================================================
-- 5. PLUGIN CONFIGURATION
-- =============================================================================

-- Colorscheme configurations
-- Arthur (no setup needed - simple colorscheme)
-- Autumn (no setup needed - simple colorscheme)

-- Black Metal
pcall(function()
	require("black-metal").setup()
end)

-- Gruvbox
pcall(function()
	require("gruvbox").setup({
		invert_selection = true,
		contrast = "hard",
		overrides = {},
	})
end)

-- Nightfox
pcall(function()
	require("nightfox").setup({
		styles = {
			comments = "italic",
			keywords = "bold",
			functions = "bold",
		},
	})
end)

-- OneDark
pcall(function()
	require("onedark").setup({
		style = "darker",
	})
end)

-- Tokyonight
pcall(function()
	require("tokyonight").setup({
		style = "night",
		transparent = false,
		terminal_colors = true,
		styles = {
			comments = { italic = true },
			keywords = { italic = true },
		},
	})
end)

-- Vague
pcall(function()
	require("vague").setup({})
end)

-- Apply selected colorscheme
pcall(function()
	vim.cmd.colorscheme(theme_config.colorscheme)
end)

-- Gitsigns
pcall(function()
	require("gitsigns").setup({
		signs = {
			add = { text = "│" },
			change = { text = "│" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		current_line_blame = false,
	})
end)

-- Lualine (status line)
pcall(function()
	require("lualine").setup({
		options = {
			theme = "tokyonight",
			component_separators = { left = "|", right = "|" },
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff" },
			lualine_c = { "filename" },
			lualine_x = {
				{
					"diagnostics",
					sources = { "nvim_lsp" },
					symbols = { error = " ", warn = " ", info = " ", hint = " " },
				},
				"encoding",
				"fileformat",
				"filetype",
			},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	})
end)

-- FzfLua
pcall(function()
	require("fzf-lua").setup({
		winopts = {
			border = "single",
			preview = {
				border = "single",
			},
		},
	})
end)

-- Yazi
pcall(function()
	require("yazi").setup({
		open_for_directories = false,
		keymaps = {
			show_help = "<f1>",
		},
	})
end)

-- LuaSnip (Snippet Engine)
pcall(function()
	local luasnip = require("luasnip")

	luasnip.setup({
		history = true,
		updateevents = "TextChanged,TextChangedI",
		enable_autosnippets = false,
		store_selection_keys = "<Tab>",
	})

	-- Load VSCode-style snippets from friendly-snippets
	require("luasnip.loaders.from_vscode").lazy_load()

	-- Load custom VSCode-style snippets from snippets/ directory
	require("luasnip.loaders.from_vscode").lazy_load({
		paths = { vim.fn.stdpath("config") .. "/snippets" },
	})

	-- Key mappings for snippet expansion and navigation
	-- Use Ctrl+Space to manually trigger snippet expansion
	vim.keymap.set("i", "<C-Space>", function()
		if luasnip.expandable() then
			luasnip.expand()
		end
	end, { silent = true, desc = "Expand snippet" })

	-- Jump forward through snippet tabstops
	vim.keymap.set({ "i", "s" }, "<C-j>", function()
		if luasnip.jumpable(1) then
			luasnip.jump(1)
		end
	end, { silent = true, desc = "Jump to next snippet field" })

	-- Jump backward through snippet tabstops
	vim.keymap.set({ "i", "s" }, "<C-k>", function()
		if luasnip.jumpable(-1) then
			luasnip.jump(-1)
		end
	end, { silent = true, desc = "Jump to previous snippet field" })

	-- Cycle through snippet choices
	vim.keymap.set({ "i", "s" }, "<C-l>", function()
		if luasnip.choice_active() then
			luasnip.change_choice(1)
		end
	end, { silent = true, desc = "Cycle through snippet choices" })
end)

-- Conform.nvim (Code Formatting)
pcall(function()
	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_format", "ruff_fix" },
			r = { "styler" },
			sh = { "shfmt" },
			bash = { "shfmt" },
			markdown = { "mdformat" },
			nix = { "alejandra" },
			yaml = { "prettier" },
			json = { "prettier" },
			javascript = { "prettier" },
			typescript = { "prettier" },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
	})
end)

-- Mini.nvim (4 modules: icons, pairs, surround, indentscope)
pcall(function()
	-- Mini.icons: Provide icons for files, filetypes, etc.
	require("mini.icons").setup()

	-- Mini.pairs: Auto-pair brackets, quotes, etc.
	require("mini.pairs").setup()

	-- Mini.surround: Add/delete/replace surroundings (quotes, brackets, etc.)
	require("mini.surround").setup({
		mappings = {
			add = "sa", -- Add surrounding
			delete = "sd", -- Delete surrounding
			find = "sf", -- Find surrounding (to the right)
			find_left = "sF", -- Find surrounding (to the left)
			highlight = "sh", -- Highlight surrounding
			replace = "sr", -- Replace surrounding
			update_n_lines = "sn", -- Update `n_lines`
		},
	})

	-- Mini.indentscope: Animate indentation scope
	require("mini.indentscope").setup({
		symbol = "│",
		options = { try_as_border = true },
	})
end)

-- Flash.nvim (Enhanced jump motions)
pcall(function()
	require("flash").setup({
		labels = "asdfghjklqwertyuiopzxcvbnm",
		search = {
			multi_window = true,
			forward = true,
			wrap = true,
		},
		jump = {
			jumplist = true,
			pos = "start",
			history = false,
			register = false,
		},
		label = {
			uppercase = true,
			rainbow = {
				enabled = true,
				shade = 5,
			},
		},
		modes = {
			search = {
				enabled = true,
			},
			char = {
				enabled = true,
				jump_labels = true,
			},
		},
	})

	-- Flash keymaps
	vim.keymap.set({ "n", "x", "o" }, "s", function()
		require("flash").jump()
	end, { desc = "Flash" })

	vim.keymap.set({ "n", "x", "o" }, "S", function()
		require("flash").treesitter()
	end, { desc = "Flash Treesitter" })

	vim.keymap.set("o", "r", function()
		require("flash").remote()
	end, { desc = "Remote Flash" })

	vim.keymap.set({ "o", "x" }, "R", function()
		require("flash").treesitter_search()
	end, { desc = "Treesitter Search" })

	vim.keymap.set({ "c" }, "<c-s>", function()
		require("flash").toggle()
	end, { desc = "Toggle Flash Search" })
end)

-- Which-key.nvim (Keymap help)
pcall(function()
	require("which-key").setup({
		preset = "modern",
		delay = 500,
		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "+",
		},
		win = {
			border = "single",
		},
	})

	-- Register key groups
	require("which-key").add({
		{ "<leader>b", group = "Buffer" },
		{ "<leader>c", group = "Code" },
		{ "<leader>d", group = "Diagnostics" },
		{ "<leader>e", group = "Explorer" },
		{ "<leader>f", group = "Find" },
		{ "<leader>g", group = "Git" },
		{ "<leader>l", group = "LSP" },
		{ "<leader>lc", group = "LSP Calls" },
		{ "<leader>m", group = "Markdown" },
		{ "<leader>p", group = "Persistence" },
		{ "<leader>s", group = "Search" },
		{ "<leader>t", group = "Toggle" },
		{ "<leader>w", group = "Window" },
	})
end)

-- Copilot.vim (GitHub Copilot AI assistance)
-- No configuration needed - works out of the box
-- Run :Copilot setup on first use to authenticate
-- Default keybindings:
--   <Tab> to accept suggestion
--   <C-]> to dismiss
--   <M-]> next suggestion
--   <M-[> previous suggestion

-- Vim-tmux-navigator (Seamless vim/tmux navigation)
-- No configuration needed - works out of the box with default keybindings
-- <C-h>, <C-j>, <C-k>, <C-l> to navigate between vim and tmux panes

-- =============================================================================
-- 5a. LAZY-LOADED PLUGIN CONFIGURATIONS
-- =============================================================================

-- Quarto-nvim: Load on quarto filetype
vim.api.nvim_create_autocmd("FileType", {
	pattern = "quarto",
	callback = function()
		vim.cmd.packadd("quarto-nvim")
		pcall(function()
			require("quarto").setup({
				debug = false,
				closePreviewOnExit = true,
				lspFeatures = {
					enabled = true,
					languages = { "r", "python", "julia", "bash" },
					diagnostics = {
						enabled = true,
						triggers = { "BufWritePost" },
					},
					completion = {
						enabled = true,
					},
				},
				codeRunner = {
					enabled = false,
					default_method = nil,
				},
			})
		end)
	end,
	once = true,
})

-- Otter.nvim: Load on quarto filetype (for embedded language LSP)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "quarto",
	callback = function()
		vim.cmd.packadd("otter.nvim")
		pcall(function()
			require("otter").setup({
				lsp = {
					hover = {
						border = "single",
					},
				},
				buffers = {
					set_filetype = true,
				},
			})
			-- Activate otter for the buffer
			require("otter").activate({ "r", "python", "julia", "bash" })
		end)
	end,
	once = true,
})

-- Obsidian.nvim: Load on markdown filetype
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.cmd.packadd("obsidian.nvim")
		pcall(function()
			require("obsidian").setup({
				workspaces = {
					{
						name = "notes",
						path = "~/Documents/notes",
					},
				},
				completion = {
					nvim_cmp = false,
				},
				ui = {
					enable = false,
				},
			})
		end)
	end,
	once = true,
})

-- Render-markdown.nvim: Load on markdown and quarto filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "quarto" },
	callback = function()
		vim.cmd.packadd("render-markdown.nvim")
		pcall(function()
			require("render-markdown").setup({
				enabled = true,
				heading = {
					enabled = true,
					sign = true,
					icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
				},
				code = {
					enabled = true,
					sign = true,
					style = "full",
					left_pad = 0,
					right_pad = 0,
				},
				bullet = {
					enabled = true,
					icons = { "●", "○", "◆", "◇" },
				},
			})
		end)
	end,
	once = true,
})

-- Vim-markdown: Load on markdown and quarto filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "quarto" },
	callback = function()
		vim.cmd.packadd("vim-markdown")
		-- Vim-markdown configuration (global variables)
		vim.g.vim_markdown_folding_disabled = 1
		vim.g.vim_markdown_frontmatter = 1
		vim.g.vim_markdown_toml_frontmatter = 1
		vim.g.vim_markdown_json_frontmatter = 1
		vim.g.vim_markdown_math = 1
		vim.g.vim_markdown_strikethrough = 1
	end,
	once = true,
})

-- CMP-pandoc-references: Load on markdown and quarto filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "quarto" },
	callback = function()
		vim.cmd.packadd("cmp-pandoc-references")
		-- No setup needed - works with nvim-cmp
	end,
	once = true,
})

-- LazyGit: Load on command
vim.api.nvim_create_user_command("LazyGit", function()
	vim.cmd.packadd("lazygit.nvim")
	pcall(function()
		require("lazygit").lazygit()
	end)
end, { desc = "Open LazyGit" })

-- LazyGitCurrentFile: Load on command
vim.api.nvim_create_user_command("LazyGitCurrentFile", function()
	vim.cmd.packadd("lazygit.nvim")
	pcall(function()
		require("lazygit").lazygit_current_file()
	end)
end, { desc = "Open LazyGit for current file" })

-- LazyGitFilter: Load on command
vim.api.nvim_create_user_command("LazyGitFilter", function(opts)
	vim.cmd.packadd("lazygit.nvim")
	pcall(function()
		require("lazygit").lazygit_filter(opts.args)
	end)
end, { nargs = 1, desc = "Open LazyGit with filter" })

-- LazyGitFilterCurrentFile: Load on command
vim.api.nvim_create_user_command("LazyGitFilterCurrentFile", function()
	vim.cmd.packadd("lazygit.nvim")
	pcall(function()
		require("lazygit").lazygit_filter_current_file()
	end)
end, { desc = "Open LazyGit filter for current file" })

-- Nvim-colorizer: Load on command
vim.api.nvim_create_user_command("ColorizerToggle", function()
	vim.cmd.packadd("nvim-colorizer.lua")
	pcall(function()
		require("colorizer").setup()
		vim.cmd("ColorizerToggle")
	end)
end, { desc = "Toggle colorizer" })

-- =============================================================================
-- 5. LSP CONFIGURATION
-- =============================================================================

-- Diagnostic configuration
vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	virtual_text = {
		prefix = "●",
		severity = {
			min = vim.diagnostic.severity.INFO,
			max = vim.diagnostic.severity.WARN,
		},
	},
	signs = true,
	underline = true,
	float = {
		border = "single",
		source = "if_many",
	},
})

-- Diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- LSP on_attach function
local on_attach = function(client, bufnr)
	local opts = { buffer = bufnr, silent = true }

	-- LSP key mappings
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "grt", vim.lsp.buf.type_definition, opts) -- NEW in 0.12!
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>f", function()
		vim.lsp.buf.format({ async = true })
	end, opts)

	-- Incremental selection (NEW in 0.12!)
	vim.keymap.set("n", "an", vim.lsp.buf.selection_range, opts)
end

-- Configure language servers using new vim.lsp.config API (0.12+)

-- R Language Server
vim.lsp.config("r_language_server", {
	cmd = { "R", "--slave", "-e", "languageserver::run()" },
	filetypes = { "r", "rmd" },
	root_markers = { ".git", "DESCRIPTION", ".Rproj.user" },
	on_attach = on_attach,
	settings = {
		r = {
			lsp = {
				diagnostics = true,
			},
		},
	},
})

-- TypeScript/JavaScript
vim.lsp.config("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	on_attach = on_attach,
})

-- Lua
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		".git",
	},
	on_attach = on_attach,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
})

-- Bash
vim.lsp.config("bashls", {
	cmd = { "bash-language-server", "start" },
	filetypes = { "sh", "bash" },
	root_markers = { ".git" },
	on_attach = on_attach,
})

-- Nix
vim.lsp.config("nil_ls", {
	cmd = { "nil" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", "default.nix", ".git" },
	on_attach = on_attach,
	settings = {
		["nil"] = {
			formatting = {
				command = { "nixpkgs-fmt" },
			},
		},
	},
})

-- Python
vim.lsp.config("pyright", {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
	on_attach = on_attach,
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "workspace",
				useLibraryCodeForTypes = true,
			},
		},
	},
})

-- YAML with Quarto schema support
vim.lsp.config("yamlls", {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yml" },
	root_markers = { ".git" },
	on_attach = on_attach,
	settings = {
		yaml = {
			schemas = {
				-- Quarto schema for .qmd YAML headers
				["https://raw.githubusercontent.com/quarto-dev/quarto-cli/main/src/resources/yaml-intelligence-resources/quarto-editor-schema.json"] = "*.qmd",
			},
			validate = true,
			hover = true,
			completion = true,
		},
	},
})

-- Enable language servers for their respective filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"r",
		"rmd",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"lua",
		"sh",
		"bash",
		"nix",
		"python",
		"yaml",
		"yml",
	},
	callback = function(args)
		local server_map = {
			r = "r_language_server",
			rmd = "r_language_server",
			javascript = "ts_ls",
			javascriptreact = "ts_ls",
			typescript = "ts_ls",
			typescriptreact = "ts_ls",
			lua = "lua_ls",
			sh = "bashls",
			bash = "bashls",
			nix = "nil_ls",
			python = "pyright",
			yaml = "yamlls",
			yml = "yamlls",
		}
		local server = server_map[vim.bo[args.buf].filetype]
		if server then
			vim.lsp.enable(server)
		end
	end,
})

-- =============================================================================
-- 6. TREESITTER CONFIGURATION
-- =============================================================================

pcall(function()
	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"r",
			"javascript",
			"typescript",
			"tsx",
			"lua",
			"bash",
			"nix",
			"markdown",
			"markdown_inline",
			"html",
			"css",
			"json",
			"yaml",
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		indent = {
			enable = true,
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<CR>",
				node_incremental = "<CR>",
				scope_incremental = "<S-CR>",
				node_decremental = "<BS>",
			},
		},
	})

	-- Enable folding based on treesitter
	vim.opt.foldmethod = "expr"
	vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
	vim.opt.foldenable = false -- Don't fold by default
end)

-- =============================================================================
-- 7. KEY MAPPINGS
-- =============================================================================

-- Escape and mode switching -----
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<Esc>", "<Esc><cmd>nohlsearch<CR>", { desc = "Clear highlights" })

-- Save and quit -----
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<C-a>", "<cmd>wa<CR>", { desc = "Save all files" })
vim.keymap.set("n", "<C-x>", "<cmd>qa!<CR>", { desc = "Quit all, do not save" })
vim.keymap.set("n", "<leader>x", "<cmd>qa!<CR>", { desc = "Quit all, do not save" })
vim.keymap.set("n", "<leader>wx", "<cmd>wa<Bar>qa!<CR>", { desc = "Save all and quit" })
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Navigation -----
-- Line beginning/end
vim.keymap.set({ "n", "v" }, "gh", "^", { desc = "Go to line beginning" })
vim.keymap.set({ "n", "v" }, "gl", "$", { desc = "Go to line end" })
-- Add blank line below/above
vim.keymap.set("n", "gO", "<cmd>put! =repeat(nr2char(10), v:count1)<CR>", { desc = "Add blank line above" })
vim.keymap.set("n", "go", "<cmd>put =repeat(nr2char(10), v:count1)<CR>", { desc = "Add blank line below" })
-- Visual line movement
vim.keymap.set("n", "j", "gj", { desc = "Next visual line" })
vim.keymap.set("n", "k", "gk", { desc = "Previous visual line" })
-- Centered scrolling
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered" })

-- Window management -----
-- NOTE: <C-h>, <C-j>, <C-k>, <C-l> are managed by vim-tmux-navigator
-- for seamless navigation between vim and tmux panes
-- Window resize
vim.keymap.set("n", "<leader>wk", "<C-w>10-", { desc = "Resize window up" })
vim.keymap.set("n", "<leader>wj", "<C-w>10+", { desc = "Resize window down" })
vim.keymap.set("n", "<leader>wh", "<C-w>10<", { desc = "Resize window left" })
vim.keymap.set("n", "<leader>wl", "<C-w>10>", { desc = "Resize window right" })

-- Editing -----
-- Move lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })
-- Paste without overwriting register
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without overwrite" })

-- Buffer management -----
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Close other buffers" })
vim.keymap.set("n", "<leader>bf", "<cmd>FzfLua buffers<CR>", { desc = "Find buffer" })

-- Code actions -----
vim.keymap.set("n", "<leader>ca", "<cmd>FzfLua lsp_code_actions<CR>", { desc = "Code actions" })
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format code" })
vim.keymap.set("n", "<leader>cn", "<cmd>s/\\s\\+/ /g<CR>", { desc = "Remove extra spaces (line)" })
vim.keymap.set("v", "<leader>cn", ":s/\\s\\+/ /g<CR>", { desc = "Remove extra spaces (selection)" })

-- Diagnostics -----
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show diagnostics" })

-- Explorer -----
vim.keymap.set("n", "<leader>ey", "<cmd>Yazi<CR>", { desc = "Yazi file explorer" })
vim.keymap.set("n", "<leader>ec", "<cmd>Yazi cwd<CR>", { desc = "Yazi in cwd" })

-- Files (FzfLua) -----
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New file" })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<CR>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua resume<CR>", { desc = "Resume FzfLua" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>", { desc = "Help tags" })

-- LSP navigation -----
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "<leader>lD", "<cmd>FzfLua lsp_definitions<CR>", { desc = "Definitions" })
vim.keymap.set("n", "<leader>lt", "<cmd>FzfLua lsp_typedefs<CR>", { desc = "Type definitions" })
vim.keymap.set("n", "<leader>li", "<cmd>FzfLua lsp_implementations<CR>", { desc = "Implementations" })
vim.keymap.set("n", "<leader>lr", "<cmd>FzfLua lsp_references<CR>", { desc = "References" })
vim.keymap.set("n", "<leader>ls", "<cmd>FzfLua lsp_document_symbols<CR>", { desc = "Document symbols" })
vim.keymap.set("n", "<leader>lS", "<cmd>FzfLua lsp_workspace_symbols<CR>", { desc = "Workspace symbols" })
vim.keymap.set("n", "<leader>ln", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>lh", vim.lsp.buf.signature_help, { desc = "Signature help" })
vim.keymap.set("n", "<leader>lci", "<cmd>FzfLua lsp_incoming_calls<CR>", { desc = "Incoming calls" })
vim.keymap.set("n", "<leader>lco", "<cmd>FzfLua lsp_outgoing_calls<CR>", { desc = "Outgoing calls" })

-- Markdown formatting -----
-- Lists
vim.keymap.set("n", "<leader>mu", "I- ", { desc = "Unordered list item" })
vim.keymap.set("v", "<leader>mu", ":s/^/- /g<CR>gv", { desc = "Unordered list item" })
vim.keymap.set("n", "<leader>mo", "I1. ", { desc = "Ordered list item" })
vim.keymap.set("v", "<leader>mo", ":s/^/1. /g<CR>gv", { desc = "Ordered list item" })
vim.keymap.set("n", "<leader>mt", "I- [ ] ", { desc = "Task list item" })
vim.keymap.set("v", "<leader>mt", ":s/^/- [ ] /<CR>gv", { desc = "Task list item" })
-- Text formatting
vim.keymap.set("v", "<leader>mb", 'c**<C-r>"**<Esc>', { desc = "Bold" })
vim.keymap.set("v", "<leader>mi", 'c*<C-r>"*<Esc>', { desc = "Italic" })
vim.keymap.set("v", "<leader>ms", 'c~~<C-r>"~~<Esc>', { desc = "Strikethrough" })
vim.keymap.set("v", "<leader>mh", 'c==<C-r>"==<Esc>', { desc = "Highlight (==mark==)" })
-- Code blocks
vim.keymap.set("v", "<leader>mc", 'c```\n<C-r>"\n```<Esc>', { desc = "Code block" })
vim.keymap.set("v", "<leader>mC", 'c`<C-r>"`<Esc>', { desc = "Inline code" })
-- Headings
vim.keymap.set("n", "<leader>m1", "I# <Esc>", { desc = "Heading 1" })
vim.keymap.set("n", "<leader>m2", "I## <Esc>", { desc = "Heading 2" })
vim.keymap.set("n", "<leader>m3", "I### <Esc>", { desc = "Heading 3" })
vim.keymap.set("n", "<leader>m4", "I#### <Esc>", { desc = "Heading 4" })
-- Links
vim.keymap.set("v", "<leader>ml", 'c[<C-r>"]()<Left>', { desc = "Add link" })

-- Search -----
vim.keymap.set("n", "<leader>sh", "<cmd>FzfLua helptags<CR>", { desc = "Search help" })
vim.keymap.set("n", "<leader>sk", "<cmd>FzfLua keymaps<CR>", { desc = "Search keymaps" })
vim.keymap.set("n", "<leader>sm", "<cmd>FzfLua marks<CR>", { desc = "Search marks" })
vim.keymap.set("n", "<leader>sr", "<cmd>FzfLua registers<CR>", { desc = "Search registers" })
vim.keymap.set("n", "<leader>ss", "<cmd>FzfLua spell_suggest<CR>", { desc = "Spelling suggestions" })

-- Session persistence -----
vim.keymap.set("n", "<leader>ps", "<cmd>lua Session_save_prompt()<CR>", { desc = "Save session" })
vim.keymap.set("n", "<leader>pl", "<cmd>lua Session_load_last()<CR>", { desc = "Load last session" })
vim.keymap.set("n", "<leader>pS", "<cmd>lua Session_select()<CR>", { desc = "Select session" })

-- Toggle functions -----
vim.keymap.set("n", "<leader>ts", "<cmd>lua Toggle_spell()<CR>", { desc = "Toggle spell" })
vim.keymap.set("n", "<leader>tw", "<cmd>lua Toggle_wrap()<CR>", { desc = "Toggle wrap" })

-- Git (lazygit.nvim - lazy-loaded) -----
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })
vim.keymap.set("n", "<leader>gf", "<cmd>LazyGitCurrentFile<CR>", { desc = "LazyGit current file" })
vim.keymap.set("n", "<leader>gF", "<cmd>LazyGitFilterCurrentFile<CR>", { desc = "LazyGit filter current file" })

-- Colorizer (nvim-colorizer - lazy-loaded) -----
vim.keymap.set("n", "<leader>tc", "<cmd>ColorizerToggle<CR>", { desc = "Toggle colorizer" })

-- =============================================================================
-- 8. UI AND AESTHETICS
-- =============================================================================

-- Use new 0.12 highlight groups for enhanced diff
vim.api.nvim_set_hl(0, "DiffTextAdd", { bg = "#3d5213", fg = "#b4fa72" })

-- Enhanced popup menu appearance with new 0.12 highlights
vim.api.nvim_set_hl(0, "PmenuBorder", { fg = "#7aa2f7" })

-- =============================================================================
-- 8. CUSTOM FUNCTIONS
-- =============================================================================

-- Session management helpers -----
local session_dir = vim.fn.stdpath("state") .. "/sessions"

local function ensure_session_dir()
	if vim.fn.isdirectory(session_dir) == 0 then
		vim.fn.mkdir(session_dir, "p")
	end
end

local function normalize_session_name(name)
	local normalized = (name or "last"):gsub("%.vim$", "")
	normalized = normalized:gsub("%s+", "_")
	normalized = normalized:gsub("[^%w%._%-]", "")
	if normalized == "" then
		normalized = "last"
	end
	return normalized
end

local function session_path(name)
	ensure_session_dir()
	local normalized = normalize_session_name(name)
	return session_dir .. "/" .. normalized .. ".vim"
end

local function session_save(name, opts)
	opts = opts or {}
	local target = session_path(name)
	local ok, err = pcall(vim.cmd, "mksession! " .. vim.fn.fnameescape(target))
	if not ok then
		if not opts.silent then
			vim.notify("Session save failed: " .. err, vim.log.levels.ERROR)
		end
		return
	end
	if not opts.silent then
		vim.notify("Session saved to " .. target, vim.log.levels.INFO)
	end
	return target
end

local function session_load(name, opts)
	opts = opts or {}
	local target = session_path(name)
	if vim.fn.filereadable(target) == 0 then
		if not opts.silent then
			vim.notify("Session not found: " .. target, vim.log.levels.WARN)
		end
		return
	end
	local ok, err = pcall(vim.cmd, "source " .. vim.fn.fnameescape(target))
	if not ok then
		if not opts.silent then
			vim.notify("Session load failed: " .. err, vim.log.levels.ERROR)
		end
		return
	end
	if not opts.silent then
		vim.notify("Session loaded from " .. target, vim.log.levels.INFO)
	end
end

local function session_list()
	ensure_session_dir()
	local files = vim.fn.readdir(session_dir, function(file)
		return file:sub(-4) == ".vim"
	end)
	table.sort(files)
	return files
end

function _G.Session_save_prompt()
	local name = vim.fn.input("Save session name (last): ", "", "file")
	if name == "" then
		name = "last"
	end
	session_save(name)
end

function _G.Session_load_last()
	session_load("last")
end

function _G.Session_select()
	local files = session_list()
	if vim.tbl_isempty(files) then
		vim.notify("No sessions saved in " .. session_dir, vim.log.levels.INFO)
		return
	end
	vim.ui.select(files, { prompt = "Select session" }, function(choice)
		if choice then
			session_load(choice)
		end
	end)
end

-- Toggle functions -----
function _G.Toggle_spell()
	vim.opt.spell = not vim.opt.spell:get()
	local status = vim.opt.spell:get() and "enabled" or "disabled"
	vim.notify("Spell checking " .. status, vim.log.levels.INFO)
end

function _G.Toggle_wrap()
	vim.opt.wrap = not vim.opt.wrap:get()
	local status = vim.opt.wrap:get() and "enabled" or "disabled"
	vim.notify("Word wrap " .. status, vim.log.levels.INFO)
end

-- =============================================================================
-- 9. AUTOCMDS
-- =============================================================================

-- Create autocommand group
local augroup = vim.api.nvim_create_augroup("nvim_dev", { clear = true })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = "*",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

-- Auto-create directories when saving
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Auto-save session on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = augroup,
	callback = function()
		if vim.fn.argc() > 0 then
			session_save("last", { silent = true })
		end
	end,
})

-- Markdown/Quarto heading navigation
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "quarto" },
	callback = function()
		vim.keymap.set(
			"n",
			"]]",
			"/^#\\+\\s.*$<CR>:nohlsearch<CR>",
			{ buffer = true, silent = true, desc = "Next heading" }
		)
		vim.keymap.set(
			"n",
			"[[",
			"?^#\\+\\s.*$<CR>:nohlsearch<CR>",
			{ buffer = true, silent = true, desc = "Previous heading" }
		)
	end,
})

-- Quarto files: set define pattern for navigation
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = augroup,
	pattern = "*.qmd",
	callback = function()
		vim.bo.filetype = "quarto"
		vim.bo.define = "^\\s*#\\+\\s*"
	end,
})

-- Spell language management
local function get_project_root()
	local current_file = vim.fn.expand("%:p")
	if current_file == "" then
		return nil
	end
	local path = vim.fn.fnamemodify(current_file, ":h")
	while path ~= "" and path ~= "/" do
		if vim.fn.isdirectory(path .. "/.git") == 1 or vim.fn.filereadable(path .. "/.nvim_spell_lang") == 1 then
			return path
		end
		path = vim.fn.fnamemodify(path, ":h")
	end
	return nil
end

local function load_spell_lang()
	local project_root = get_project_root()
	if not project_root then
		return
	end
	local spell_lang_file = project_root .. "/.nvim_spell_lang"
	if vim.fn.filereadable(spell_lang_file) == 1 then
		local lang = vim.trim(vim.fn.readfile(spell_lang_file)[1])
		vim.opt_local.spelllang = lang
	else
		vim.opt_local.spelllang = "en_us"
	end
end

vim.api.nvim_create_autocmd("BufEnter", {
	group = augroup,
	callback = function()
		load_spell_lang()
	end,
})

-- Spell language command
local function set_spell_lang(lang)
	local project_root = get_project_root()
	if not project_root then
		vim.notify("Not in a project directory", vim.log.levels.WARN)
		return
	end
	local spell_lang_file = project_root .. "/.nvim_spell_lang"
	vim.fn.writefile({ lang }, spell_lang_file)
	vim.opt_local.spelllang = lang
	vim.notify("Spell language set to " .. lang, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("SpellLang", function()
	vim.ui.select({ "en_us", "es" }, {
		prompt = "Select spell language:",
	}, function(choice)
		if choice then
			set_spell_lang(choice)
		end
	end)
end, {})

-- =============================================================================
-- END OF CONFIGURATION
-- =============================================================================
