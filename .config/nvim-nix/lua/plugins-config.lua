-- Plugin Configurations for Neovim 0.11.x
-- Uses native vim.lsp.config API (no nvim-lspconfig dependency)

local capabilities = vim.lsp.protocol.make_client_capabilities()

--=============================================================================
-- Treesitter (newer API - no longer uses 'configs' module)
--=============================================================================

-- nvim-treesitter now uses simpler setup via init.lua
local ts_ok, treesitter = pcall(require, "nvim-treesitter")
if ts_ok and treesitter.setup then
	treesitter.setup({
		highlight = { enable = true },
		indent = { enable = true },
	})
end

-- Incremental selection keymaps (manual setup for newer treesitter)
vim.keymap.set("n", "gnn", function()
	require("nvim-treesitter.incremental_selection").init_selection()
end, { desc = "Init treesitter selection" })
vim.keymap.set("x", "grn", function()
	require("nvim-treesitter.incremental_selection").node_incremental()
end, { desc = "Increment node selection" })
vim.keymap.set("x", "grm", function()
	require("nvim-treesitter.incremental_selection").node_decremental()
end, { desc = "Decrement node selection" })

--=============================================================================
-- LSP Configuration with native vim.lsp.config (Neovim 0.11+)
--=============================================================================

-- Lua
vim.lsp.config.lua_ls = {
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
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
}

-- Python
vim.lsp.config.pyright = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
		".git",
	},
	capabilities = capabilities,
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
}

-- Nix
vim.lsp.config.nixd = {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", ".git" },
	capabilities = capabilities,
}

-- Go
vim.lsp.config.gopls = {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
	capabilities = capabilities,
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			staticcheck = true,
		},
	},
}

-- Bash
vim.lsp.config.bashls = {
	cmd = { "bash-language-server", "start" },
	filetypes = { "bash", "sh" },
	root_markers = { ".git" },
	capabilities = capabilities,
}

-- Markdown
vim.lsp.config.marksman = {
	cmd = { "marksman", "server" },
	filetypes = { "markdown", "markdown.mdx" },
	root_markers = { ".marksman.toml", ".git" },
	capabilities = capabilities,
}

-- Typst
vim.lsp.config.tinymist = {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	root_markers = { ".git" },
	capabilities = capabilities,
}

-- YAML
vim.lsp.config.yamlls = {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
	root_markers = { ".git" },
	capabilities = capabilities,
	settings = {
		yaml = {
			schemas = {
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
			},
		},
	},
}

-- JSON
vim.lsp.config.jsonls = {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	root_markers = { ".git" },
	capabilities = capabilities,
}

-- Enable all configured LSP servers
vim.lsp.enable({
	"lua_ls",
	"pyright",
	"nixd",
	"gopls",
	"bashls",
	"marksman",
	"tinymist",
	"yamlls",
	"jsonls",
})

--=============================================================================
-- Completion with blink.cmp
--=============================================================================

local blink_ok, blink = pcall(require, "blink.cmp")
if blink_ok then
	blink.setup({
		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},
		keymap = {
			preset = "default",
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
		},
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			providers = {
				emoji = {
					module = "blink-emoji",
					name = "Emoji",
					score_offset = 15,
					opts = { insert = true },
				},
			},
		},
		snippets = { preset = "luasnip" },
		completion = {
			accept = {
				auto_brackets = {
					enabled = true,
				},
			},
			menu = {
				border = "rounded",
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 500,
				window = {
					border = "rounded",
				},
			},
		},
	})
end

--=============================================================================
-- Luasnip
--=============================================================================

local luasnip_ok, luasnip_loaders = pcall(require, "luasnip.loaders.from_vscode")
if luasnip_ok then
	luasnip_loaders.lazy_load()
end

--=============================================================================
-- Conform (formatting)
--=============================================================================

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format", "ruff_fix" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		json = { "prettier" },
		markdown = { "prettier" },
		nix = { "alejandra" },
		sh = { "shfmt" },
		bash = { "shfmt" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

--=============================================================================
-- Snacks
--=============================================================================

local Snacks = require("snacks")
Snacks.setup({
	picker = {
		enabled = true,
		ui_select = true,
	},
	notifier = { enabled = false }, -- Disabled: compatibility issue with 0.11.x
	statuscolumn = { enabled = true },
	input = { enabled = true },
	image = { enabled = true },
	indent = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	words = { enabled = true },
	gitbrowse = { enabled = true },
	lazygit = { enabled = true },
	terminal = { enabled = true },
	dashboard = {
		enabled = true,
		sections = {
			{ section = "header" },
		},
	},
	bufdelete = { enabled = true },
	rename = { enabled = true },
	win = {
		border = "rounded",
	},
})

-- Explicitly set vim.ui functions to use Snacks
vim.ui.select = Snacks.picker.select
vim.ui.input = Snacks.input

--=============================================================================
-- Gitsigns
--=============================================================================

require("gitsigns").setup({
	signs = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
})

--=============================================================================
-- Which-key
--=============================================================================

require("which-key").setup({
	preset = "helix",
	delay = 500,
	plugins = {
		marks = true,
		registers = true,
		spelling = {
			enabled = true,
			suggestions = 20,
		},
	},
	win = {
		border = "rounded",
		padding = { 2, 2, 2, 2 },
	},
})

--=============================================================================
-- Aerial (code outline)
--=============================================================================

require("aerial").setup({
	backends = { "treesitter", "lsp", "markdown", "man" },
	layout = {
		max_width = { 40, 0.2 },
		width = nil,
		min_width = 10,
		win_opts = {},
		default_direction = "prefer_right",
		placement = "window",
		preserve_equality = false,
	},
})

--=============================================================================
-- Render markdown
--=============================================================================

require("render-markdown").setup({
	file_types = { "markdown", "quarto" },
	render_modes = { "n", "c" },
	completions = { blink = { enabled = true } },
	-- Disable features for missing treesitter parsers
	html = { enabled = false },
	latex = { enabled = false },
})

--=============================================================================
-- Obsidian
--=============================================================================

require("obsidian").setup({
	legacy_commands = false,
	workspaces = {
		{
			name = "notes",
			path = "~/Obsidian/Notes",
		},
	},
	-- Disable obsidian UI to avoid conflict with render-markdown
	ui = { enable = false },
	completion = {
		nvim_cmp = false,
		blink = true,
	},
	picker = {
		name = "snacks.pick",
	},
	new_notes_location = "notes_subdir",
	preferred_link_style = "wiki",
	templates = {
		subdir = "Templates",
		date_format = "%Y-%m-%d",
		time_format = "%H:%M",
	},
	daily_notes = {
		folder = "Daily",
		date_format = "%Y-%m-%d",
		alias_format = "%B %-d, %Y",
		template = "Daily Note Template.md",
	},
	attachments = {
		folder = "Attachments",
	},
})

--=============================================================================
-- Quarto
--=============================================================================

require("quarto").setup({
	debug = false,
	closePreviewOnExit = true,
	lspFeatures = {
		enabled = true,
		chunks = "curly",
		languages = { "r", "python", "julia", "bash", "lua", "html", "dot" },
		diagnostics = {
			enabled = true,
			triggers = { "BufWritePost" },
		},
		completion = {
			enabled = true,
		},
	},
	codeRunner = {
		enabled = true,
		default_method = "slime",
		ft_runners = {
			bash = "slime",
		},
		never_run = { "yaml" },
	},
})

--=============================================================================
-- Mini.surround
--=============================================================================

require("mini.surround").setup({
	mappings = {
		add = "sa",
		delete = "sd",
		find = "sf",
		find_left = "sF",
		highlight = "sh",
		replace = "sr",
		update_n_lines = "sn",
	},
})

--=============================================================================
-- Todo-comments
--=============================================================================

require("todo-comments").setup({
	signs = true,
	sign_priority = 8,
	keywords = {
		FIX = {
			icon = " ",
			color = "error",
			alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
		},
		TODO = { icon = " ", color = "info" },
		HACK = { icon = " ", color = "warning" },
		WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
		PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
		NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
		TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
	},
	merge_keywords = true,
	highlight = {
		before = "",
		keyword = "wide",
		after = "fg",
		pattern = [[.*<(KEYWORDS)\s*:]],
		comments_only = true,
		max_line_len = 400,
		exclude = {},
	},
	colors = {
		error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
		warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
		info = { "DiagnosticInfo", "#2563EB" },
		hint = { "DiagnosticHint", "#10B981" },
		default = { "Identifier", "#7C3AED" },
		test = { "Identifier", "#FF00FF" },
	},
	search = {
		command = "rg",
		args = {
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
		},
		pattern = [[\b(KEYWORDS):]],
	},
})

--=============================================================================
-- Yazi
--=============================================================================

require("yazi").setup({
	open_for_directories = false,
	keymaps = {
		show_help = "<F1>",
		open_file_in_vertical_split = "<C-v>",
		open_file_in_horizontal_split = "<C-x>",
		open_file_in_tab = "<C-t>",
		grep_in_directory = "<C-s>",
		replace_in_directory = "<C-g>",
		cycle_open_buffers = "<Tab>",
		copy_relative_path_to_selected_files = "<C-y>",
		send_to_quickfix_list = "<C-q>",
		change_working_directory = "<C-d>",
	},
	yazi_floating_window_winblend = 0,
	yazi_floating_window_scaling_factor = 0.9,
	log_level = vim.log.levels.OFF,
})

--=============================================================================
-- CopilotChat
--=============================================================================

require("CopilotChat").setup({
	model = "gpt-4o",
	agent = "copilot",
	temperature = 0.1,
	debug = false,
	show_help = true,
	window = {
		layout = "vertical",
		width = 0.3,
		height = 0.4,
		border = "rounded",
	},
	mappings = {
		complete = {
			insert = "<Tab>",
		},
		close = {
			normal = "q",
			insert = "<C-c>",
		},
		reset = {
			normal = "<C-l>",
			insert = "<C-l>",
		},
		submit_prompt = {
			normal = "<CR>",
			insert = "<C-s>",
		},
		accept_diff = {
			normal = "<C-y>",
			insert = "<C-y>",
		},
		yank_diff = {
			normal = "gy",
		},
		show_diff = {
			normal = "gd",
		},
		show_info = {
			normal = "gi",
		},
		show_context = {
			normal = "gc",
		},
		show_help = {
			normal = "gh",
		},
	},
})

--=============================================================================
-- LazyGit (no setup needed - just provides :LazyGit command)
--=============================================================================

vim.g.lazygit_floating_window_winblend = 0
vim.g.lazygit_floating_window_scaling_factor = 0.9

--=============================================================================
-- Tabout
--=============================================================================

require("tabout").setup({
	tabkey = "<Tab>",
	backwards_tabkey = "<S-Tab>",
	act_as_tab = true,
	act_as_shift_tab = false,
	default_tab = "<C-t>",
	default_shift_tab = "<C-d>",
	enable_backwards = true,
	completion = false,
	tabouts = {
		{ open = "'", close = "'" },
		{ open = '"', close = '"' },
		{ open = "`", close = "`" },
		{ open = "(", close = ")" },
		{ open = "[", close = "]" },
		{ open = "{", close = "}" },
	},
	exclude = {},
})

--=============================================================================
-- CSV View
--=============================================================================

require("csvview").setup({
	parser = {
		async_chunksize = 50,
		comments = { "#", "//" },
	},
	view = {
		display_mode = "highlight",
		min_column_width = 5,
		spacing = 2,
	},
})

--=============================================================================
-- Highlight colors
--=============================================================================

require("nvim-highlight-colors").setup({
	render = "background",
	enable_named_colors = true,
	enable_tailwind = false,
})

--=============================================================================
-- img-clip
--=============================================================================

require("img-clip").setup({
	default = {
		embed_image_as_base64 = false,
		prompt_for_file_name = false,
		drag_and_drop = {
			insert_mode = true,
		},
		use_absolute_path = true,
	},
})

--=============================================================================
-- Quicker (quickfix enhancements)
--=============================================================================

require("quicker").setup({
	keys = {
		{
			">",
			function()
				require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
			end,
			desc = "Expand quickfix context",
		},
		{
			"<",
			function()
				require("quicker").collapse()
			end,
			desc = "Collapse quickfix context",
		},
	},
})

--=============================================================================
-- Diagnostics Configuration
--=============================================================================

vim.diagnostic.config({
	underline = false,
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
	},
})

--=============================================================================
-- Statusline
--=============================================================================

vim.o.statusline = table.concat({
	"%#StatusLineModeNormal#",
	" %{v:lua.Get_mode_name()} ",
	"%#StatusLineModified#",
	"%{&modified?' [+]':''}",
	"%#StatusLine#",
	"%{&readonly?' []':''} ",
	"%#StatusLineGit#",
	"%{v:lua.Get_git_branch()}",
	"%#StatusLineFilename#",
	" %t ",
	"%#StatusLine#",
	"%=",
	"%{v:lua.Get_diagnostic_status()}",
	"%#StatusLineSearch#",
	"%{v:lua.Get_search_count()}",
	"%#StatusLineModeNormal#",
	" %Y ",
	"%#StatusLine#",
	" %3l:%-2c ",
	"%#StatusLineModeNormal#",
	" %p%% ",
	"%#StatusLine#",
}, "")

--=============================================================================
-- Gruvbox Theme (Default - will be overridden by theme-config.lua)
--=============================================================================

require("gruvbox").setup({
	terminal_colors = true,
	undercurl = true,
	underline = true,
	bold = true,
	italic = {
		strings = true,
		emphasis = true,
		comments = true,
		operators = false,
		folds = true,
	},
	strikethrough = true,
	invert_selection = false,
	invert_signs = false,
	invert_tabline = false,
	invert_intend_guides = false,
	inverse = true,
	contrast = "hard",
	palette_overrides = {},
	overrides = {},
	dim_inactive = false,
	transparent_mode = false,
})

-- Apply colorscheme from theme-config if available
local ok, theme_config = pcall(require, "theme-config")
if ok and theme_config.colorscheme then
	vim.cmd("colorscheme " .. theme_config.colorscheme)
else
	vim.cmd("colorscheme gruvbox")
end

-- Statusline highlights (gruvbox-based, will match most themes)
vim.api.nvim_set_hl(0, "StatusLineModeNormal", { bg = "#7c6f64", fg = "#fbf1c7", bold = true })
vim.api.nvim_set_hl(0, "StatusLineModeInsert", { bg = "#b8bb26", fg = "#282828", bold = true })
vim.api.nvim_set_hl(0, "StatusLineModeVisual", { bg = "#fe8019", fg = "#282828", bold = true })
vim.api.nvim_set_hl(0, "StatusLineModified", { fg = "#fb4934", bold = true })
vim.api.nvim_set_hl(0, "StatusLineGit", { fg = "#b8bb26", bg = "#3c3836" })
vim.api.nvim_set_hl(0, "StatusLineFilename", { fg = "#ebdbb2", bg = "#504945", bold = true })
vim.api.nvim_set_hl(0, "StatusLineSearch", { fg = "#fabd2f", bg = "#3c3836" })
