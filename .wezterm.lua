--[[
WezTerm Configuration File
-------------------------
This configuration file customizes the WezTerm terminal emulator with:
- Custom keybindings for pane and tab management
- Theme and appearance settings
- Font configuration
- Special R programming shortcuts
]]
--

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-----------------------------------------------------------
-- GENERAL SETTINGS
-----------------------------------------------------------
-- Basic performance and behavior settings
config.send_composed_key_when_left_alt_is_pressed = true
config.max_fps = 120

-----------------------------------------------------------
-- TAB BAR CUSTOMIZATION
-----------------------------------------------------------
-- Custom tab title formatting
wezterm.on("format-tab-title", function(tab, _, _, _, _)
  local active_pane = wezterm.get_active_pane()
  if active_pane then
    return string.format("%s (Pane ID: %s)", tab.active_domain, active_pane.id)
  end
  return tab.active_domain
end)

-- Tab bar appearance settings
config.show_new_tab_button_in_tab_bar = false
config.show_tab_index_in_tab_bar = false
config.tab_bar_at_bottom = false
config.show_close_tab_button_in_tabs = false

-----------------------------------------------------------
-- KEYBINDINGS
-----------------------------------------------------------
local act = wezterm.action

config.keys = {
  -- R Programming Shortcuts
  { key = "-", mods = "ALT",        action = act.SendString(" <- ") }, -- Assignment operator
  { key = "m", mods = "ALT",        action = act.SendString(" |>") }, -- Pipe operator

  -- Pane Management
  { key = "|", mods = "CTRL|SHIFT", action = act.SplitHorizontal },    -- Split pane horizontally
  { key = "_", mods = "CTRL|SHIFT", action = act.SplitVertical },      -- Split pane vertically
  { key = "M", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState }, -- Toggle zoom state

  -- Pane Navigation (ALT + number to switch)
  { key = "1", mods = "ALT",        action = act.ActivatePaneByIndex(0) },
  { key = "2", mods = "ALT",        action = act.ActivatePaneByIndex(1) },
  { key = "3", mods = "ALT",        action = act.ActivatePaneByIndex(2) },
  { key = "4", mods = "ALT",        action = act.ActivatePaneByIndex(3) },

  -- Pane Resizing
  { key = "H", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "J", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "K", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "L", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

  -- Utility Functions
  { key = "S", mods = "CTRL|SHIFT", action = act.PaneSelect({ alphabet = "123456789", show_pane_ids = true }) },
  { key = "0", mods = "CMD",        action = act.ResetFontSize },

  -- Tab Management
  {
    key = "I",
    mods = "CTRL|SHIFT",
    action = act.PromptInputLine({
      description = "Name",
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

-----------------------------------------------------------
-- FONT CONFIGURATION
-----------------------------------------------------------
config.font_size = 14
config.font = wezterm.font("Hack Nerd Font", { weight = "Regular", italic = false })
config.line_height = 1.1
config.pane_select_font_size = 40

-----------------------------------------------------------
-- WINDOW APPEARANCE
-----------------------------------------------------------
config.window_decorations = "RESIZE"
config.window_frame = {
  font_size = 15,
  font = wezterm.font({ family = "Hack Nerd Font", weight = "Bold" }),
  active_titlebar_bg = "#000000",
  inactive_titlebar_bg = "#cccccc",
}

-----------------------------------------------------------
-- COLOR SCHEME
-----------------------------------------------------------
-- Detect and set appropriate color scheme based on system appearance
local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return "Dark"
end

local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "Gruvbox dark, hard (base16)"
  else
    return "Gruvbox light, hard (base16)"
  end
end

config.color_scheme = scheme_for_appearance(get_appearance())

-- Custom colors configuration
config.colors = {
  cursor_bg = "#FB4A34",
  indexed = {
    -- Base colors
    [16] = "#121212", -- Background shades
    [17] = "#444444",
    [18] = "#121212",
    [19] = "#222222",
    [20] = "#999999",

    -- Radian specific colors
    [102] = "#FB4A34", -- Selection
    [109] = "#B9BB25", -- Syntax
    [231] = "#B9BB25", -- Parentheses
    [241] = "#FB4A34", -- Parentheses
    [251] = "#FB4A34", -- Cursor
    [253] = "#FB4A34", -- Text
  },
  tab_bar = {
    active_tab = {
      fg_color = "#000000",
      bg_color = "#ffffff",
    },
  },
}

return config
