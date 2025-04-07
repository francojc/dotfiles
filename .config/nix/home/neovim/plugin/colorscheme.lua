-- Colorscheme configuration

-- Gruvbox
require("gruvbox").setup({
	invert_selection = true,
	contrast = "hard",
	overrides = {},
})

-- Tokyonight
require("tokyonight").setup({
	style = "night",
	overrides = {},
})

-- Set colorscheme
vim.cmd("colorscheme gruvbox")
