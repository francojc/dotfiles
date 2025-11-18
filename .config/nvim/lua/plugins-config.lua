---| PLUGINS CONFIGURATION ------------------------------------------------

---| UPFRONT ---------------------------------------------------
-- Load theme config early for colors used by plugins
local theme_config = require("theme-config")
local colors = theme_config.colors

---=============================================================
---| COMPLETION & SNIPPETS
---=============================================================

---| Blink.cmp ----------------------------------
require("blink.cmp").setup({
	fuzzy = {
		implementation = "lua",
	},
	snippets = {
		expand = function(snippet)
			vim.snippet.expand(snippet)
		end,
	},
	completion = {
		list = {
			selection = {
				preselect = false,
				auto_insert = false,
			},
		},
		menu = {
			auto_show = true,
			auto_show_delay_ms = 1000,
			draw = {
				columns = {
					{ "kind_icon", "label", "label_description", gap = 1 },
					{ "kind", "source_name", gap = 1 },
				},
			},
		},
		documentation = { auto_show = true },
	},
	keymap = {
		-- preset = "enter", -- with mods
		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "cancel", "fallback" },
		["<CR>"] = { "select_and_accept", "fallback" },

		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },

		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback_to_mappings" },
		["<C-n>"] = { "select_next", "fallback_to_mappings" },

		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },

		["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
	},
	signature = {
		enabled = true,
		window = {
			show_documentation = true,
		},
	},
	sources = {
		default = { "path", "snippets", "lsp", "buffer" },
		per_filetype = {
			markdown = { "path", "snippets", "lsp", "references", "emoji" },
			quarto = { "path", "snippets", "lsp", "references", "emoji" },
		},
		providers = {
			snippets = {
				name = "snippets",
				module = "blink.cmp.sources.snippets",
				opts = {
					friendly_snippets = true,
					search_paths = { vim.fn.stdpath("config") .. "/snippets" },
				},
			},
			emoji = {
				name = "Emoji",
				module = "blink-emoji",
			},
			references = {
				name = "pandoc_references",
				module = "cmp-pandoc-references.blink",
			},
		},
	},
	cmdline = {
		completion = {
			menu = {
				auto_show = function()
					return vim.fn.getcmdtype() == ":"
				end,
			},
		},
		keymap = {
			preset = "inherit",
		},
	},
})

---============================================================
---| COLORSCHEMES & THEMING
---============================================================

---| Arthur ----------------------------------
-- (No setup required)

---| Autumn ----------------------------------
-- (No setup required)

---| Black Metal ----------------------------------
require("black-metal").setup({
	diagnostics = {
		darker = false,
	},
})

---| Catppuccin ----------------------------------
require("catppuccin").setup({
	flavour = "mocha", -- latte, frappe, macchiato, mocha
	background = { -- :h background
		light = "latte",
		dark = "mocha",
	},
	transparent_background = false,
	show_end_of_buffer = false,
	term_colors = false,
	compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
	styles = {
		comments = { "italic" },
		conditionals = { "italic" },
		loops = {},
		functions = {},
		keywords = {},
		strings = {},
		variables = {},
		numbers = {},
		booleans = {},
		properties = {},
		types = {},
		operators = {},
	},
	integrations = {
		treesitter = true,
		native_lsp = {
			enabled = true,
			virtual_text = {
				errors = { "italic" },
				hints = { "italic" },
				warnings = { "italic" },
				information = { "italic" },
			},
			underlines = {
				errors = { "underline" },
				hints = { "underline" },
				warnings = { "underline" },
				information = { "underline" },
			},
			inlay_hints = {
				background = true,
			},
		},
	},
})

---| Gruvbox ----------------------------------
require("gruvbox").setup({
	invert_selection = true,
	contrast = "hard",
	overrides = {},
})

---| Nightfox ----------------------------------
require("nightfox").setup({
	styles = {
		comments = "italic",
		keywords = "bold",
		functions = "bold",
	},
})

---| OneDark ----------------------------------
require("onedark").setup({
	style = "darker",
})

---| Tokyo Night ----------------------------------
require("tokyonight").setup({
	style = "storm", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night`, and `day`
	light_style = "day", -- The theme is used when the background is set to light
	transparent = false, -- Enable this to disable setting the background color
	terminal_colors = true, -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
	styles = {
		-- Style to be applied to different syntax groups
		-- Value is any valid attr-list value for `:highlight` command
		comments = { italic = true },
		keywords = { italic = true },
		functions = {},
		variables = {},
		-- Background styles. Can be "dark", "transparent" or "normal"
		sidebars = "dark", -- style for sidebars, see below
		floats = "dark", -- style for floating windows
	},
	sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
	day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
	hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **StatusLineNC** highlights
	dim_inactive = false, -- dims inactive windows
})

---| Vague ----------------------------------
require("vague").setup({})

---| VS Code ----------------------------------
require("vscode").setup({
	-- Alternatively set style in setup
	style = "dark",
	-- Enable transparent background
	transparent = false,
	-- Enable italic comment
	italic_comments = false,
	-- Disable nvim-tree background color
	disable_nvimtree_bg = true,
	-- Override colors (see ./lua/vscode/colors.lua)
	color_overrides = {
		vscLineNumber = "#FFFFFF",
	},
	-- Override highlight groups (see ./lua/vscode/theme.lua)
	group_overrides = {
		-- this supports the same val table as vim.api.nvim_set_hl
		-- example:
		Comment = { fg = "#FF0000", bg = "#0000FF", italic = true },
	},
})

---| Activate Colorscheme ----------------------------------
if theme_config.colorscheme == "ayu" then
	vim.g.ayucolor = "mirage" -- set ayu theme to mirage
end

vim.cmd("colorscheme " .. theme_config.colorscheme)

---| Statusline Highlights (theme-adaptive) ----------------------------------
require("statusline-highlights").setup()

-- Re-apply statusline highlights when colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		require("statusline-highlights").setup()
	end,
	desc = "Update statusline highlights when colorscheme changes",
})

---| Neovim 0.12+ Highlight Groups ----------------------------------
vim.api.nvim_set_hl(0, "DiffTextAdd", { bg = "#3d5213", fg = "#b4fa72" })
vim.api.nvim_set_hl(0, "PmenuBorder", { fg = colors.blue or "#7aa2f7" })

---============================================================
---| CODE FORMATTING
---============================================================

---| Conform ----------------------------------
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
		quarto = { "injected" },
		r = { "air" },
		["*"] = { "trim_whitespace" },
	},
	formatters = {
		injected = {
			options = {
				ignore_errors = false,
				lang_to_ext = {
					bash = "sh",
					python = "py",
					r = "r",
				},
			},
		},
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

---===========================================================
---| LANGUAGE SERVERS (LSP)
---===========================================================
-- Get enhanced LSP capabilities from blink.cmp
local capabilities = require("blink.cmp").get_lsp_capabilities()

---| Shell & System ----------------------------------

-- Bash (bash-language-server)
vim.lsp.config.bashls = {
	capabilities = capabilities,
	filetypes = { "sh", "bash" },
}

---| Nix Ecosystem ----------------------------------

-- Nix (nixd)
local function get_home_dir()
	return os.getenv("HOME") or "~"
end

local function get_hostname()
	return os.getenv("HOSTNAME") or vim.loop.os_gethostname() or ""
end

vim.lsp.config.nixd = {
	cmd = { "nixd" },
	capabilities = capabilities,
	filetypes = { "nix" },
	settings = {
		nixd = {
			nixpkgs = { expr = "import <nixpkgs> {}" },
			formatting = { command = { "alejandra" } },
			options = {
				nixos = {
					expr = '(builtins.getFlake get_home_dir() .. "/.dotfiles/.config/nix").nixosConfigurations.'
						.. get_hostname()
						.. ".options",
				},
				nix_darwin = {
					expr = '(builtins.getFlake get_home_dir() .. "/.dotfiles/.config/nix").darwinConfigurations.'
						.. get_hostname()
						.. ".options",
				},
				home_manager = {
					expr = '(builtins.getFlake get_home_dir() .. "/.dotfiles/.config/nix").homeConfigurations.'
						.. get_hostname()
						.. ".options",
				},
			},
		},
	},
}

---| Lua Development ----------------------------------

-- Lua (lua-language-server)
vim.lsp.config.lua_ls = {
	on_attach = function(client, _)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	capabilities = capabilities,
	filetypes = { "lua" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim", "require" },
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					vim.fn.stdpath("config"),
				},
			},
			telemetry = {
				enable = false,
			},
		},
	},
	root_dir = function(fname)
		return vim.fs.root(fname, { ".git", ".luarc.json", "init.lua" }) or vim.fs.dirname(fname)
	end,
}

---| Python Development ----------------------------------

-- Python (pyright)
vim.lsp.config.pyright = {
	capabilities = capabilities,
	filetypes = { "python" },
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic",
				diagnosticMode = "workspace",
				autoImportCompletions = true,
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
	root_dir = function(fname)
		return vim.fs.root(fname, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" })
			or vim.fs.dirname(fname)
	end,
}

-- Copilot (copilot-language-server)
vim.g.copilot_enabled = true -- Disable Copilot by default
vim.lsp.config.copilot = {
	capabilities = capabilities,
	filetypes = { "*" }, -- Enable for all filetypes
}

---| R & Data Science ----------------------------------

-- R Language Server
vim.lsp.config.r_language_server = {
	on_attach = function(client, _)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	cmd = { "R", "--slave", "-e", "languageserver::run()" },
	filetypes = { "r", "rmd", "quarto" },
	capabilities = capabilities,
	root_dir = function(fname)
		return vim.fs.root(fname, "DESCRIPTION") or vim.fs.root(fname, ".git") or vim.fs.dirname(fname)
	end,
	settings = {
		r = {
			lsp = {
				diagnostics = true,
				rich_documentation = true, -- Enhanced hover documentation
			},
		},
	},
}

-- YAML (yaml-language-server) - for Quarto configuration
local function get_quarto_resource_path()
	-- error handling for io.popen
	local ok, f = pcall(io.popen, "quarto --paths", "r")
	if not ok or not f then
		return nil
	end
	-- Function to split a string by a delimiter
	local function strsplit(s, delimiter)
		local result = {}
		for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
			table.insert(result, match)
		end
		return result
	end
	local s = f:read("*a")
	f:close()
	local lines = strsplit(s, "\n")
	-- The second line is usually the system share path
	return lines[2]
end

local resource_path = get_quarto_resource_path()
local quarto_schema_path = resource_path and (resource_path .. "/schemas/quarto-schema.json") or nil

if quarto_schema_path then
	vim.lsp.config.yamlls = {
		capabilities = capabilities,
		filetypes = { "yaml", "yml" },
		settings = {
			yaml = {
				schemas = {
					[quarto_schema_path] = { "*.qmd", ".quarto.yaml", "quarto.yml", "*.quarto.yml" },
				},
				completion = true,
				validate = true,
			},
		},
	}
else
	vim.lsp.config.yamlls = {
		capabilities = capabilities,
		filetypes = { "yaml", "yml" },
	}
end

---| Documentation ----------------------------------

-- Markdown (marksman)
vim.lsp.config.marksman = {
	capabilities = capabilities,
	filetypes = { "markdown" },
}

---| LSP Auto-Enable by FileType ----------------------------------
-- Enable LSP servers based on filetype (Neovim 0.12+ pattern)
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"sh",
		"bash",
		"lua",
		"markdown",
		"nix",
		"python",
		"r",
		"rmd",
		"quarto",
		"yaml",
		"yml",
	},
	callback = function(args)
		local server_map = {
			sh = "bashls",
			bash = "bashls",
			lua = "lua_ls",
			markdown = "marksman",
			nix = "nixd",
			python = "pyright",
			r = "r_language_server",
			rmd = "r_language_server",
			quarto = "r_language_server",
			yaml = "yamlls",
			yml = "yamlls",
		}
		local server = server_map[vim.bo[args.buf].filetype]
		if server then
			vim.lsp.enable(server)
		end
	end,
})

---==========================================================
---| EDITOR ENHANCEMENTS
---==========================================================

---| Mini Modules ----------------------------------
local mini_modules = { "icons", "pairs", "surround" }
for _, module in ipairs(mini_modules) do
	require("mini." .. module).setup({})
end

-- Configure MiniSurround custom "h" to add ==…==
pcall(function()
	require("mini.surround").setup({
		custom_surroundings = {
			h = {
				-- Add with:  sa h  (then motion)
				-- Change:    sc h  (works when cursor inside ==…== if recognized)
				-- Delete:    sd h
				output = function()
					return { left = "==", right = "==" }
				end,
			},
		},
	})
end)

---| Tabout ----------------------------------
require("tabout").setup({
	tabkey = "<Tab>",
	backwards_tabkey = "<S-Tab>",
	act_as_tab = true, -- Use tab normally when tabout is unavailable
	act_as_shift_tab = false,
	default_tab = "<C-t>", -- Fallback for indent
	default_shift_tab = "<C-d>", -- Fallback for dedent
	enable_backwards = true,
	completion = true, -- Handle completion popups (blink.cmp)
	tabouts = {
		{ open = "'", close = "'" },
		{ open = '"', close = '"' },
		{ open = "`", close = "`" },
		{ open = "(", close = ")" },
		{ open = "[", close = "]" },
		{ open = "{", close = "}" },
	},
	ignore_beginning = true, -- Allow tabout from the beginning of brackets
	exclude = {}, -- No filetype exclusions
})

---| Snacks ----------------------------------
require("snacks").setup({
	bigfile = { enabled = false },
	dashboard = {
		enabled = true,
		sections = {
			{ section = "header" },
			-- { section = "keys", gap = 1, padding = 1 },
		},
	},
	explorer = { enabled = false }, -- Using yazi
	git = { enabled = false },
	gitbrowse = { enabled = false },
	image = { enabled = true }, -- Using image.nvim
	input = { enabled = false },
	notifier = { enabled = false }, -- Using standard vim.notify
	picker = {
		enabled = true,
		formatters = {
			file = {
				filename_first = true,
			},
		},
		layout = {},
	},
	quickfile = { enabled = false },
	scope = { enabled = false },
	scroll = { enabled = false },
	gh = {
		enabled = true,
		win = {
			zindex = 50,
			style = "minimal",
		},
	},
	statuscolumn = { enabled = false },
	terminal = { enabled = false },
	toggle = { enabled = true }, -- Complements toggle functions
	words = { enabled = false },
})

-- Register Snacks picker as the vim.ui.select backend
vim.ui.select = Snacks.picker.ui_select

---==========================================================
---| SYNTAX & PARSING
---==========================================================

---| Treesitter ----------------------------------
require("nvim-treesitter.configs").setup({
	auto_install = true, -- Automatically install missing parsers
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-Space>",
			node_incremental = "<C-Space>",
			scope_incremental = false,
			node_decremental = "<Backspace>",
		},
	},
	indent = { enable = false },
})

---| Otter (embedded language support) ----------------------------------
-- Otter needs to be setup eagerly for Quarto support
require("otter").setup({
	lsp = {
		diagnostic_update_events = { "BufWritePost" },
		root_dir = function(_, bufnr)
			return vim.fs.root(bufnr or 0, {
				".git",
				"_quarto.yml",
				"DESCRIPTION",
			}) or vim.fn.getcwd(0)
		end,
	},
	buffers = {
		set_filetype = true,
		write_to_disk = false,
	},
	handle_leading_whitespace = true,
})

---==========================================================
---| UI & NAVIGATION
---==========================================================

---| WhichKey ----------------------------------
require("which-key").setup({
	preset = "modern",
	icons = {
		group = "",
	},
	plugins = {
		marks = false,
		registers = false,
	},
})

-- Add keymap groups
local wk = require("which-key")
wk.add({
	{ "<leader>a", group = "Assistant", icon = "󰚩 " },
	{ "<leader>b", group = "Buffer", icon = "󰓩 " },
	{ "<leader>c", group = "Code", icon = "󰌗" },
	{ "<leader>d", group = "Diagnostics/Debug", icon = "󰒡" },
	{ "<leader>e", group = "Explore", icon = "󰥩" },
	{ "<leader>f", group = "Files", icon = "󰈔" },
	{ "<leader>g", group = "Git", icon = "󰊢" },
	{ "<leader>gi", group = "GitHub issues", icon = "󰌚" },
	{ "<leader>gp", group = "GitHub PRs", icon = "󰓁" },
	{ "<leader>h", group = "Help", icon = "󰋗" },
	{ "<leader>l", group = "LSP", icon = "󰅩" },
	{ "<leader>lc", group = "Call Hierarchy", icon = "󰘦" },
	{ "<leader>m", group = "Markdown", icon = "󰉫" },
	{ "<leader>o", group = "Obsidian", icon = "󱞁" },
	{ "<leader>p", group = "Persistence", icon = "󰆓" },
	{ "<leader>q", group = "Quarto", icon = "󰠮" },
	{ "<leader>r", group = "Run", icon = "󰒋" },
	{ "<leader>s", group = "Search", icon = "󰢶" },
	{ "<leader>t", group = "Toggle", icon = "󰔡" },
	{ "<leader>w", proxy = "<C-w>", group = "Windows", icon = "󰪷" },
	{ "<leader>x", desc = "Quit", icon = "󰗼" },
})

---==========================================================
---| LAZY-LOADED PLUGINS
---==========================================================
-- Native lazy-loading using vim.pack optional plugins and autocommands

---| Version Control ----------------------------------

-- Gitsigns (load when opening files in git repos)
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("LazyGitsigns", { clear = true }),
	callback = function()
		vim.cmd.packadd("gitsigns.nvim")
		require("gitsigns").setup({
			word_diff = false,
		})
	end,
	once = true,
})

---| Code Navigation ----------------------------------

-- Aerial code outline
require("aerial").setup({})

---| File Management ----------------------------------

-- Yazi file manager
require("yazi").setup({})

-- CSV viewer
require("csvview").setup({})

---| Visual Enhancements ----------------------------------

-- Highlight colors
require("nvim-highlight-colors").setup({})

---| Markdown & Quarto Tools ----------------------------------

-- Image viewer for Markdown/Quarto
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "quarto" },
	group = vim.api.nvim_create_augroup("LazyImage", { clear = true }),
	callback = function()
		vim.cmd.packadd("image.nvim")
		require("image").setup({
			processor = "magick_cli",
			integrations = {
				markdown = {
					clear_in_insert_mode = false,
					filetypes = { "markdown", "quarto" },
					only_render_image_at_cursor = false,
				},
			},
		})
		-- Disable by default to match the global flag
		require("image").disable()
	end,
	once = true,
})

-- Image clipboard for Markdown/Quarto
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "quarto" },
	group = vim.api.nvim_create_augroup("LazyImgClip", { clear = true }),
	callback = function()
		vim.cmd.packadd("img-clip.nvim")
		require("img-clip").setup({
			default = {
				dir_path = "./images",
				relative_to_current_file = true,
				show_dir_path_in_prompt = true,
			},
		})
	end,
	once = true,
})

-- Obsidian notes
require("obsidian").setup({
	legacy_commands = false,
	ui = {
		enable = false,
	},
	checkbox = {
		order = { " ", "x", ">", "-", "~", "!", "?" },
	},
	workspaces = {
		{
			name = "Notes",
			path = "~/Obsidian/Notes/",
		},
		{
			name = "Personal",
			path = "~/Obsidian/Personal/",
		},
	},
	daily_notes = {
		folder = "Daily",
		template = "Assets/Templates/Daily.md",
	},
	templates = {
		folder = "Assets/Templates",
	},
	new_notes_location = "Inbox",
	attachments = {
		img_folder = "Assets/Attachments",
	},
	completion = {
		nvim_cmp = false,
		blink = true,
	},
})

-- Quarto
require("quarto").setup({
	lspFeatures = {
		enabled = true,
		chunks = "curly",
		languages = { "r", "python", "julia", "bash", "html" },
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
		never_run = { "yaml" },
	},
	keymap = false,
})

-- Render Markdown
require("render-markdown").setup({
	latex = { enabled = false },
	bullet = {
		icons = { "■ ", "□ ", "▪ ", "▫ " },
		left_pad = 0,
		right_pad = 2,
	},
	checkbox = {
		unchecked = { icon = "□ ", highlight = "RenderMarkdownUnchecked" },
		checked = { icon = " ", highlight = "RenderMarkdownChecked" },
		custom = {
			waiting = {
				raw = "[?]",
				rendered = " ",
				highlight = "DiagnosticInfo",
				scope_highlight = nil,
			},
			stale = {
				raw = "[-]",
				rendered = " ",
				highlight = "DiagnosticInfo",
				scope_highlight = nil,
			},
			forward = {
				raw = "[>]",
				rendered = " ",
				highlight = "DiagnosticError",
				scope_highlight = nil,
			},
			progress = {
				raw = "[/]",
				rendered = " ",
				highlight = "DiagnosticWarn",
				scope_highlight = nil,
			},
			cancel = {
				raw = "[~]",
				rendered = " ",
				highlight = "DiagnosticError",
				scope_highlight = nil,
			},
			important = {
				raw = "[!]",
				rendered = " ",
				highlight = "DiagnosticWarn",
				scope_highlight = nil,
			},
		},
	},
	code = {
		sign = false,
		language_border = " ",
	},
	completions = {
		lsp = { enabled = true },
		blink = { enabled = true },
	},
	dash = { enabled = false },
	file_types = { "markdown", "quarto" },
	heading = {
		backgrounds = {},
		left_pad = 0,
		position = "inline",
		right_pad = 3,
		icons = {
			"# ",
			"## ",
			"### ",
			"#### ",
			"##### ",
			"###### ",
		},
	},
	html = {
		enabled = true,
		comment = { conceal = false },
	},
	pipe_table = {
		preset = "round",
	},
})
