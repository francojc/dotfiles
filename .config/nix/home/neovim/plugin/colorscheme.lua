-- Colorscheme configuration

-- Gruvbox
require("gruvbox").setup({
	invert_selection = true,
})

-- Tokyonight
require("tokyonight").setup({
	style = "night",
})

-- Set colorscheme
vim.cmd("colorscheme tokyonight")
