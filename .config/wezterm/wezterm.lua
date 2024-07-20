-- WezTerm configuration file
local wezterm = require("wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
local config = wezterm.config_builder()

-- Set leader key
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }

config.send_composed_key_when_right_alt_is_pressed = true

-- WezTerm actions
config.keys = {
  -- splitting
  {
    key = "|",
    mods = "LEADER|SHIFT",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "-",
    mods = "LEADER",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  -- resizing
  {
    key = "m",
    mods = "LEADER",
    action = wezterm.action.TogglePaneZoomState,
  },
  -- reording
  {
    key = "Space",
    mods = "LEADER",
    action = wezterm.action.RotatePanes("Clockwise"),
  },
  -- swap (select)
  {
    key = "g",
    mods = "LEADER",
    action = wezterm.action.PaneSelect({
      mode = "SwapWithActive",
    }),
  },
  -- navigation
  {
    key = "h",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Left"),
  },
  {
    key = "j",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Down"),
  },
  {
    key = "k",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Up"),
  },
  {
    key = "l",
    mods = "LEADER",
    action = wezterm.action.ActivatePaneDirection("Right"),
  },
  -- Custom keybinding for Shift + Enter
  {
    key = "Enter",
    mods = "SHIFT",
    action = wezterm.action.SendString("\x1b[27;2;13~"),
  },
  { -- Custom rename tab
    key = "E",
    mods = "CTRL|SHIFT",
    action = wezterm.action.PromptInputLine({
      description = "Enter tab name:",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

-- Set hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()
-- username/project paths clickable
table.insert(config.hyperlink_rules, {
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
  format = "https://www.github.com/$1/$3",
})

-- Set the default font
config.font = wezterm.font("MesloLGL Nerd Font Mono", { weight = "Regular" })
config.font_size = 13.5

-- Tweak the color scheme
config.colors = {
  foreground = "#D9D7CE",
  background = "#202325",
  cursor_bg = "#3043C8",
  cursor_fg = "#ffffff",
  selection_bg = "#525252",
  selection_fg = "#ffffff",
}

config.inactive_pane_hsb = {
  saturation = 1,
  brightness = 0.25,
}

-- For example, changing the color scheme:
config.color_scheme = 'Gruvbox Dark (Gogh)'

-- Window settings
config.window_padding = {
  left = 10,
  right = 10,
  top = 20,
  bottom = 10,
}

-- Cursor settings
config.default_cursor_style = "SteadyBar"
config.cursor_thickness = "300%"

-- Disable window decorations
config.window_decorations = "RESIZE"

-- WARN: Not functioning, from what I can tell...
smart_splits.apply_to_config(config, {
  -- directional keys to use in order of: left, down, up, right
  direction_keys = { "h", "j", "k", "l" },
  -- modifier keys to combine with direction_keys
  modifiers = {
    move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
    resize = "CMD", -- modifier to use for pane resize, e.g. META+h to resize to the left
  },
})

-- Modify tab appearance
config.adjust_window_size_when_changing_font_size = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.tab_max_width = 20
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

-- Modify tab title
local title_color_bg = "#D9D7CE" -- background color
-- local title_color_fg = "#D9D7CE" -- foreground color

wezterm.on("update-right-status", function(window)
  -- Get battery information
  local battery_info = wezterm.battery_info()[1]
  local battery_percentage = battery_info.state_of_charge * 100
  local state = battery_info.state

  -- Set background color and icon based on battery state
  local battery_color
  local battery_icon
  if state == "Charging" then
    battery_icon = "󰂄" -- Icon for charging (Nerd Font lightning bolt)
    battery_color = "#FFFF00" -- Yellow for charging
  elseif state == "Full" or battery_percentage > 69 then
    battery_icon = "󱊣" -- Icon for full (Nerd Font battery-full)
    battery_color = "#008800" -- Green for full
  elseif state == "Discharging" then
    battery_icon = "󱊢" -- Icon for discharging (Nerd Font battery-half)
    if battery_percentage < 20 then
      battery_icon "󱊡"
      battery_color = "#FF0000" -- Red for low battery
    else
      battery_color = "#D9D7CE" -- Default color for discharging
    end
  elseif state == "Empty" then
    battery_icon = "󰂃" -- Icon for empty (Nerd Font battery-empty)
    battery_color = "#FF0000" -- Red for empty
  else
    battery_icon = "󰂑" -- Icon for unknown (Nerd Font question mark)
    battery_color = "#808080" -- Grey for unknown state
  end

  -- Get current time
  local time = wezterm.strftime("%H:%M")
  -- Get current date: in Apr 15 format
  local date = wezterm.strftime("%b %d")

  -- solid left arrow icon:  (0xf104) or the wide variant:  (0xe0b3)
  local LEFT_ARROW = ""

  -- Set the right status with formatted battery percentage, state, icon, and current time
  window:set_right_status(wezterm.format({
    { Attribute = { Italic = true } },
    { Foreground = { Color = battery_color } },
    { Background = { Color = "#202325" } },
    { Text = string.format(" %s %.0f%% ", battery_icon, battery_percentage) },
    { Foreground = { Color = "#fcfcfc" } },
    { Text = " " .. LEFT_ARROW .. " " .. time .. " " },
    { Text = " " .. LEFT_ARROW .. " " .. date .. " " },
    { Foreground = { Color = "#FF0000" } },
    { Text = "\u{f004} " }, -- Font Awesome icon for terminal
  }))
end)

local function tab_title(tab_info)
  local title = tab_info.tab_title

  if title and #title > 0 then
    return title
  end

  return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
  local edge_background = "#202325"
  local background = "#202325"
  local foreground = "#685C53"

  if tab.is_active then
    -- set to alarming yellow
    foreground = "#FFFF00"
  end

  local edge_foreground = background
  local title = tab_title(tab)
  title = wezterm.truncate_right(title, max_width - 2)

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = " " },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = " " },
  }
end)

-- and finally, return the configuration to wezterm
return config
