---| COLORSCHEMES & THEMING -----------------------------
-- Only the active colorscheme (from theme-config.lua) is configured at
-- startup.  Other themes are opt plugins and get their setup() called
-- on demand via switch_colorscheme().

local theme_config = require("theme-config")
local active = theme_config.colorscheme or "gruvbox"

--===========================================================================
--| Theme Setup Registry
--===========================================================================
-- Each entry: setup function called once when the theme is first activated.
-- Some themes (arthur, autumn) need no explicit setup.

--- Shared tokyonight setup (all style variants use same plugin)
local function _tokyonight_setup(style)
	require("tokyonight").setup({
		style = style,
		light_style = "day",
		transparent = false,
		terminal_colors = true,
		styles = {
			comments = { italic = true },
			keywords = { italic = true },
			functions = {},
			variables = {},
			sidebars = "dark",
			floats = "dark",
		},
		sidebars = { "qf", "help" },
		day_brightness = 0.3,
		hide_inactive_statusline = false,
		dim_inactive = false,
	})
end

local theme_setups = {
	arthur = nil,
	autumn = nil,
	["black-metal"] = function()
		require("black-metal").setup({ diagnostics = { darker = false } })
	end,
	catppuccin = function()
		require("catppuccin").setup({
			flavour = "mocha",
			background = { light = "latte", dark = "mocha" },
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
					inlay_hints = { background = true },
				},
			},
		})
	end,
	gruvbox = function()
		require("gruvbox").setup({
			invert_selection = true,
			contrast = "hard",
			overrides = {},
		})
	end,
	kanso = function()
		require("kanso").setup({
			backround = { dark = "zen" },
			foreground = "saturated",
		})
	end,
	nightfox = function()
		require("nightfox").setup({
			styles = {
				comments = "italic",
				keywords = "bold",
				functions = "bold",
			},
		})
	end,
	onedark = function()
		require("onedark").setup({ style = "darker" })
	end,
	tokyonight = function()
		_tokyonight_setup("storm")
	end,
	["tokyonight-night"] = function()
		_tokyonight_setup("night")
	end,
	["tokyonight-storm"] = function()
		_tokyonight_setup("storm")
	end,
	["tokyonight-moon"] = function()
		_tokyonight_setup("moon")
	end,
	["tokyonight-day"] = function()
		_tokyonight_setup("day")
	end,
	vague = function()
		require("vague").setup({})
	end,
	vscode = function()
		require("vscode").setup({
			style = "dark",
			transparent = false,
			italic_comments = false,
			disable_nvimtree_bg = true,
			color_overrides = { vscLineNumber = "#FFFFFF" },
			group_overrides = { Comment = { fg = "#FF0000", bg = "#0000FF", italic = true } },
		})
	end,
	ayu = function()
		vim.g.ayucolor = "mirage"
	end,
}

-- Tracks which themes have already had setup() called (within this session).
local setup_done = {}

--===========================================================================
--| Highlight Overrides (applied after every colorscheme switch)
--===========================================================================

local function apply_highlight_overrides()
	vim.api.nvim_set_hl(0, "llama_hl_fim_hint", { fg = "#918374", ctermfg = 59 })
	vim.api.nvim_set_hl(0, "llama_hl_fim_info", { fg = "#B9BB25", ctermfg = 119 })

	-- Fix undercurl leak in tmux: use underline instead for URL highlights
	vim.api.nvim_set_hl(0, "@string.special.url", { fg = "#7FB4CA", underline = true, undercurl = false })
	vim.api.nvim_set_hl(0, "@markup.link.url", { link = "@string.special.url" })

	-- Neovim 0.12+ highlight groups
	vim.api.nvim_set_hl(0, "DiffTextAdd", { bg = "#3d5213", fg = "#b4fa72" })
end

--===========================================================================
--| Colorscheme Activation
--===========================================================================

local function activate_colorscheme(name)
	-- Run setup if not already done
	local setup_fn = theme_setups[name]
	if setup_fn and not setup_done[name] then
		setup_fn()
		setup_done[name] = true
	end

	vim.cmd("colorscheme " .. name)
	apply_highlight_overrides()
	vim.g.active_colorscheme = name
end

-- Activate the configured theme at startup
activate_colorscheme(active)

-- Map colorscheme name → packadd directory name (matches plugin_name() in plugins-pack.lua)
local theme_packadd = {
	arthur        = "vim-colors-arthur",
	autumn        = "vim-autumn",
	["black-metal"] = "black-metal-theme-neovim",
	catppuccin    = "catppuccin",
	gruvbox       = "gruvbox.nvim",
	kanso         = "kanso.nvim",
	nightfox      = "nightfox.nvim",
	onedark       = "onedark.nvim",
	tokyonight         = "tokyonight.nvim",
	["tokyonight-night"] = "tokyonight.nvim",
	["tokyonight-storm"] = "tokyonight.nvim",
	["tokyonight-moon"]  = "tokyonight.nvim",
	["tokyonight-day"]   = "tokyonight.nvim",
	vague         = "vague.nvim",
	vscode        = "vscode.nvim",
	ayu           = "ayu-vim",
}

--===========================================================================
--| Runtime Theme Switcher
--===========================================================================
-- Call switch_colorscheme("tokyonight") from any Lua context to change
-- themes on the fly.  Loads the opt plugin if needed.

function _G.switch_colorscheme(name)
	if not theme_setups[name] then
		vim.notify("Unknown colorscheme: " .. name, vim.log.levels.ERROR)
		return
	end

	-- Load the opt plugin if it hasn't been loaded yet
	local pack_name = theme_packadd[name]
	if pack_name then
		pcall(vim.cmd, "packadd " .. pack_name)
	end

	activate_colorscheme(name)
	vim.notify("Colorscheme: " .. name, vim.log.levels.INFO)
end
