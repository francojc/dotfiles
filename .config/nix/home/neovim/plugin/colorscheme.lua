-- Colorscheme configuration

-- Gruvbox
require("gruvbox").setup({
	invert_selection = true,
	contrast = "hard",
})

-- Tokyonight
require("tokyonight").setup({
	style = "night",
})

-- Set colorscheme
vim.cmd("colorscheme gruvbox")
