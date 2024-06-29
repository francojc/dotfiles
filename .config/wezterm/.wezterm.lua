local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Extras
-- require("links").setup(config)
config.hyperlinks = true -- Enable hyperlink support

-- Set the default font
config.font = wezterm.font("MesloLGL Nerd Font Mono", { weight = "Regular" })
config.font_size = 13.5

-- Tweak the color scheme
config.colors = {
	foreground = "#D9D7CE",
	background = "#202325",
	cursor_bg = "#3043C8",
	cursor_fg = "#ffffff",
	selection_bg = "#685C53",
	selection_fg = "#ffffff",
}

-- For example, changing the color scheme:
config.color_scheme = "Gruvbox Dark"

-- Window settings
config.window_padding = {
	left = 10,
	right = 10,
	top = 20,
	bottom = 20,
}

-- Cursor settings
config.default_cursor_style = "SteadyBar"
config.cursor_thickness = "300%"

-- Disable window decorations and tab bar
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true

-- and finally, return the configuration to wezterm
return config
