---| COLORSCHEMES & THEMING -----------------------------
-- Load theme config early for colors used by plugins
local theme_config = require("theme-config")

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

--| Kanso ------------------------------------
require("kanso").setup({
	backround = {
		dark = "zen",
	},
	foreground = "saturated",
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
	style = "storm",
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

---| Vague ----------------------------------
require("vague").setup({})

---| VS Code ----------------------------------
require("vscode").setup({
	style = "dark",
	transparent = false,
	italic_comments = false,
	disable_nvimtree_bg = true,
	color_overrides = {
		vscLineNumber = "#FFFFFF",
	},
	group_overrides = {
		Comment = { fg = "#FF0000", bg = "#0000FF", italic = true },
	},
})

---| Activate Colorscheme ----------------------------------
if theme_config.colorscheme == "ayu" then
	vim.g.ayucolor = "mirage" -- set ayu theme to mirage
end

vim.cmd("colorscheme " .. theme_config.colorscheme)

---| llama.vim Highlight Overrides ----------------------------------
vim.api.nvim_set_hl(0, "llama_hl_fim_hint", { fg = "#918374", ctermfg = 59 })
vim.api.nvim_set_hl(0, "llama_hl_fim_info", { fg = "#B9BB25", ctermfg = 119 })

-- Fix undercurl leak in tmux: use underline instead for URL highlights
vim.api.nvim_set_hl(0, "@string.special.url", { fg = "#7FB4CA", underline = true, undercurl = false })
vim.api.nvim_set_hl(0, "@markup.link.url", { link = "@string.special.url" })

---| Neovim 0.12+ Highlight Groups ----------------------------------
vim.api.nvim_set_hl(0, "DiffTextAdd", { bg = "#3d5213", fg = "#b4fa72" })
