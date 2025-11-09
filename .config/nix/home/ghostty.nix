{
  hostname,
  theme,
  isDarwin,
  ...
}: {
  xdg.configFile."ghostty/config" = {
    text = ''
      # Ghostty config

      # UI
      font-family = "JetBrainsMono Nerd Font Mono"
      font-size = ${toString (
        if hostname == "Mac-Minicore"
        then 20
        else if hostname == "Macbook-Airborne"
        then 16
        else 14
      )}
      cursor-color = ${theme.ghostty.cursor_color}
      cursor-style = bar
      adjust-cursor-thickness = 2
      mouse-hide-while-typing = true

      ${
        if hostname == "Mini-Rover"
        then "window-decoration = none\n"
        else ""
      }

      # Tabs and windows
      # window-padding-x = 5
      # window-padding-y = 3
      window-padding-balance = true

      # Window position (macOS only)
      ${
        if isDarwin
        then "window-position-x = 0\nwindow-position-y = 0\n"
        else ""
      }

      macos-titlebar-style = hidden
      macos-window-shadow = false
      macos-icon = custom-style
      macos-icon-frame = plastic
      macos-icon-ghost-color = ${theme.ghostty.cursor_color}

      # Theme
      theme = ${theme.ghostty.theme}

      # Keybindings
      # -- R specific
      keybind = alt+m=text: |>
      keybind = alt+-=text: <-
      macos-option-as-alt = right

      # -- General
      keybind = global:ctrl+`=toggle_quick_terminal
      keybind = shift+enter=text:\n
    '';
  };
}
