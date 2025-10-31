---| PLUGINS CONFIGURATION ---------------------------------------------------

---| UPFRONT ---------------------------------------------------
-- Load theme config early for colors used by plugins
local theme_config = require("theme-config")
local colors = theme_config.colors

---| Fidget ----------------------------------
-- Setup fidget early since we override vim.notify
require("fidget").setup({
	notification = {
		-- Route vim.notify through fidget
		override_vim_notify = true,
		window = {
			winblend = 80, -- 80% transparency
			border = "rounded", -- Rounded border
		},
	},
	progress = {
		display = {
			done_icon = "✓", -- Clean checkmark for completed tasks
			done_style = "DiagnosticOk", -- Green styling for completed
			progress_icon = {
				pattern = "dots_pulse", -- Smooth pulsing animation
				period = 1,
			},
			progress_style = "DiagnosticInfo", -- Blue styling for progress
			group_style = "Title", -- Bold styling for LSP server names
			render_limit = 8, -- Limit notifications to avoid clutter
			done_ttl = 2, -- Show completed tasks for 2 seconds
		},
	},
})

-- Ensure any vim.notify calls use fidget's notifier
vim.notify = require("fidget").notify

---| CONFIG ---------------------------------------------------

---| Alpha ----------------------------------
local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set header

dashboard.section.header.val = {
	-- NEOVIM
	"                                                     ",
	"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
	"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
	"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
	"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
	"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
	"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
	"                                                     ",
}
-- Set menu
local dashboard_buttons = {
	{ "r", "  Recent files", ":FzfLua oldfiles<CR>" },
	{ "f", "  Find file", ":FzfLua files<CR>" },
	{ "g", "  Find text", ":FzfLua live_grep<CR>" },
	{ "n", "  New file", ":ene <BAR> startinsert<CR>" },
	{ "q", "  Quit Neovim", ":qa<CR>" },
}
dashboard.section.buttons.val = {}
for _, btn in ipairs(dashboard_buttons) do
	table.insert(dashboard.section.buttons.val, dashboard.button(unpack(btn)))
end

-- Set footer
dashboard.section.footer.val = function()
	local end_time = vim.loop.hrtime()
	local start_time = _G.nvim_config_start_time or end_time -- Fallback if start time wasn't set
	local duration_ns = end_time - start_time
	local ms = math.floor(duration_ns / 1000000 + 0.5) -- Convert ns to ms and round
	return " Welcome back, " .. os.getenv("USER") .. "! Loaded in " .. ms .. "ms"
end

-- Configure alpha options to handle UI automatically
dashboard.config.opts.setup = function()
	vim.opt_local.foldenable = false
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.opt_local.signcolumn = "no"
	vim.b.ministatusline_disable = true
	vim.b.miniindentscope_disable = true
end

-- Send config to alpha
alpha.setup(dashboard.config)

---| Blink ----------------------------------
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

---| Bufferline ----------------------------------
require("bufferline").setup({
	highlights = {
		fill = {
			fg = colors.fg,
			bg = colors.bg,
		},
		close_button = {
			fg = colors.fg,
			bg = colors.bg,
		},
		close_button_visible = {
			fg = colors.fg,
			bg = colors.bg,
		},
		close_button_selected = {
			fg = colors.fg,
			bg = colors.bg,
		},
		background = {
			italic = false,
			bold = false,
			fg = colors.fg,
			bg = colors.bg,
		},
		buffer_visible = {
			italic = false,
			bold = false,
			fg = colors.fg,
			bg = colors.bg,
		},
		buffer_selected = {
			italic = false,
			bold = true,
			fg = colors.yellow,
			bg = colors.bg,
		},
		modified = {
			bg = colors.bg,
		},
		modified_selected = {
			bg = colors.bg,
		},
		separator = {
			bg = colors.bg,
		},
		separator_visible = {
			bg = colors.bg,
		},
		separator_selected = {
			bg = colors.yellow,
			fg = colors.yellow,
		},
		offset_separator = {
			bg = colors.bg,
		},
		pick_selected = {
			bg = colors.bg,
		},
		pick_visible = {
			bg = colors.bg,
		},
		pick = {
			bg = colors.bg,
			bold = true,
			italic = true,
		},
		indicator_selected = {
			fg = colors.yellow,
			bg = colors.bg,
		},
	},
	options = {
		color_icons = true,
		separator_style = "thin",
		indicator = {
			style = "icon",
			icon = "▎",
		},
	},
})

---| Colorscheme ----------------------------------
-- Arthur
-- Autumn
-- Black Metal
require("black-metal").setup()
-- Catppuccin
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
-- Gruvbox
require("gruvbox").setup({
	invert_selection = true,
	contrast = "hard",
	overrides = {},
})
-- Nightfox
require("nightfox").setup({
	styles = {
		comments = "italic",
		keywords = "bold",
		functions = "bold",
	},
})
-- OneDark
require("onedark").setup({
	style = "darker",
})
-- Tokyo Night
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
	lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
})
-- Vague
require("vague").setup({})
-- VS Code
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

vim.cmd("colorscheme " .. theme_config.colorscheme) -- Set colorscheme from theme

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

---| FZF ----------------------------------
require("fzf-lua").setup({
	file_icon_padding = " ",
	files = {
		git_icons = true,
		formatter = "path.filename_first",
	},
	oldfiles = {
		cwd_only = true,
		include_current_session = true,
	},
})

-- Register fzf-lua as the vim.ui.select backend
require("fzf-lua").register_ui_select()

---| LSP Configuration --------------------------------
-- Get enhanced LSP capabilities from blink.cmp
-- Define capabilities early so other LSP configs can access it
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Bash
-- bash-language-server
vim.lsp.config.bashls = { capabilities = capabilities }

-- Copilot
-- copilot-language-server (for sidekick.nvim NES feature)
vim.lsp.config.copilot = {
	capabilities = capabilities,
	filetypes = { "*" }, -- Enable for all filetypes
}

-- Lua
-- lua-language-server
vim.lsp.config.lua_ls = { capabilities = capabilities }

-- Nix
-- nixd
local function get_home_dir()
	return os.getenv("HOME") or "~"
end

local function get_hostname()
	return os.getenv("HOSTNAME") or vim.loop.os_gethostname() or ""
end

vim.lsp.config.nixd = {
	cmd = { "nixd" },
	capabilities = capabilities,
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

-- Python
vim.lsp.config.pyright = { capabilities = capabilities }

-- R
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

-- YAML
-- yaml-language-server

-- Dynamically detect Quarto YAML schema and configure yamlls
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
	vim.lsp.config.yamlls = { capabilities = capabilities }
end

---| Lualine ----------------------------------
-- Create a Lua function that will match status for lualine
local function search_match_status()
	if vim.v.hlsearch == 0 then
		return ""
	end
	local search_count = vim.fn.searchcount({ recompute = true, maxcount = 999 })
	if search_count.total == 0 then
		return ""
	end
	return string.format(" %d/%d", search_count.current, search_count.total)
end

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = " ", right = " " },
		section_separators = { left = " ", right = " " },
		disabled_filetypes = {
			statusline = { "toggleterm", "alpha", "aerial" },
			winbar = { "alpha" },
		},
		always_divide_middle = true,
		globalstatus = false, -- conflicts with statusline = 2
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = {
			{ "filename", path = 1 },
		},
		lualine_x = {},
		lualine_y = {
			search_match_status, -- Custom function to show search match status
			{ "filetype", colored = true, icon_only = true, icon = { align = "right" } },
		},
		lualine_z = { "progress" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
})

---| Mini -----------------------------------
local mini_modules = { "icons", "pairs", "indentscope", "surround" }
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

---| Flash ----------------------------------
require("flash").setup({})

---| Sidekick ----------------------------------
-- Custom Sidekick NES Highlights (Copilot-style ghost text)
require("sidekick-highlights").setup()

require("sidekick").setup({
	nes = {
		enabled = false, -- Next Edit Suggestions - start disabled for manual control
	},
	cli = {
		enabled = true, -- AI CLI terminal
		win = {
			style = "float", -- Use floating window for terminal
		},
		mux = {
			backend = "tmux", -- Use tmux for persistent sessions
			enabled = true,
		},
		-- Pre-configured AI tools (aider, claude, etc.)
		tools = {
			-- Tools will be auto-detected from PATH
			-- You can customize them here if needed
		},
	},
})

---| Snacks ----------------------------------
require("snacks").setup({
	bigfile = { enabled = false },
	dashboard = { enabled = false }, -- Using alpha-nvim
	explorer = { enabled = false }, -- Using yazi
	image = { enabled = false }, -- Using image.nvim
	input = { enabled = false }, -- DISABLED: May conflict with sidekick CLI
	notifier = { enabled = false }, -- Using fidget/notify
	picker = { enabled = false }, -- Using fzf-lua
	quickfile = { enabled = false },
	scope = { enabled = false },
	scroll = { enabled = false },
	statuscolumn = { enabled = false },
	terminal = { enabled = true }, -- Terminal utilities
	toggle = { enabled = true }, -- Complements toggle functions
	words = { enabled = false },
})

---| Treesitter -----------------------------------
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

---| Otter ----------------------------------
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

---| WhichKey -----------------------------------
require("which-key").setup({
	icons = {
		group = "",
	},
})
-- add keymap groups
local wk = require("which-key")
wk.add({
	{ "<leader>a", group = "Assistant", icon = "󰚩 " },
	{ "<leader>b", group = "Buffer", icon = "󰓩 " },
	{ "<leader>c", group = "Code", icon = "󰌗" },
	{ "<leader>d", group = "Diagnostics/Debug", icon = "󰒡" },
	{ "<leader>e", group = "Explore", icon = "󰥩" },
	{ "<leader>f", group = "Files", icon = "󰈔" },
	{ "<leader>g", group = "Git", icon = "󰊢" },
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
