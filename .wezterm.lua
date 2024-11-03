local wezterm = require("wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
local config = wezterm.config_builder()

wezterm.on("format-tab-title", function(tab, tabs, panes, config, window)
  local active_pane = wezterm.get_active_pane()
  if active_pane then
    return string.format("%s (Pane ID: %s)", tab.active_domain, active_pane.id)
  end
  return tab.active_domain -- Default if no active pane
end)

-- Leader key
-- config.leader = { key = "SHIFT", mods = "CTRL" }
config.send_composed_key_when_left_alt_is_pressed = true

-- Set the default keybindings --------------
local act = wezterm.action

config.keys = {
  -- Send sequence
  { key = "-", mods = "ALT",        action = act.SendString(" <- ") },
  { key = "m", mods = "ALT",        action = act.SendString(" |>") },
  -- Manage panes
  { key = "|", mods = "CTRL|SHIFT", action = act.SplitHorizontal },
  { key = "_", mods = "CTRL|SHIFT", action = act.SplitVertical },
  { key = "M", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
  { key = "1", mods = "ALT",        action = act.ActivatePaneByIndex(0) },
  { key = "2", mods = "ALT",        action = act.ActivatePaneByIndex(1) },
  { key = "3", mods = "ALT",        action = act.ActivatePaneByIndex(2) },
  { key = "4", mods = "ALT",        action = act.ActivatePaneByIndex(3) },
  -- Adjust pane size
  { key = "H", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "J", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "K", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "L", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
  -- Get pane identifier
  { key = "S", mods = "CTRL|SHIFT", action = act.PaneSelect({ alphabet = "123456789", show_pane_ids = true }) },
  { key = "0", mods = "CMD",        action = act.ResetFontSize },
  -- Manage tabs
  {
    key = "I",
    mods = "CTRL|SHIFT",
    action = act.PromptInputLine({
      description = "Name",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

-- Config options --------------
config.font_size = 15
config.font = wezterm.font("JetBrains Mono", { weight = "Regular", italic = false })

config.window_decorations = "RESIZE"
config.show_new_tab_button_in_tab_bar = false
config.show_tab_index_in_tab_bar = false
config.tab_bar_at_bottom = false

config.pane_select_font_size = 40

config.window_frame = {
  font_size = 15,
  font = wezterm.font({ family = "Hack Nerd Font", weight = "Bold" }),
  active_titlebar_bg = "#000000",
  inactive_titlebar_bg = "#cccccc",
}

config.color_scheme = "Black Metal (base16)"

config.colors = {
  cursor_bg = "#FF5A7B",
  cursor_fg = "#cccccc",
  indexed = {
    [16] = "#121212",
    [17] = "#444444",
    [18] = "#121212",
    [19] = "#222222",
    [20] = "#999999",
    [21] = "#999999",
  },
  brights = {
    "#888888",
    "#5f8787",
    "#dd9999",
    "#a06666",
    "#888888",
    "#999999",
    "#aaaaaa",
    "#c1c1c1",
  },
  tab_bar = {
    active_tab = {
      fg_color = "#000000",
      bg_color = "#ffffff",
    },
  },
}

config.show_close_tab_button_in_tabs = false

-- Return the config ------------
return config
