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
        then 22
        else if hostname == "Macbook-Airborne"
        then 18
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

      # New splits inherit cwd of current surface (mirrors tmux `-c pane_current_path`)
      split-inherit-working-directory = true

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

      # Width calculation - use legacy (wcswidth) to match tmux's expectations
      grapheme-width-method = legacy

      # Theme
      theme = ${theme.ghostty.theme}

      # Keybindings ------
      # -- R specific
      keybind = alt+m=text: |>
      keybind = alt+-=text: <-
      macos-option-as-alt = right

      # -- General
      keybind = global:ctrl+`=toggle_quick_terminal

      # Splits — directional, mirrors tmux C-a h/j/k/l semantics
      # h = side-by-side, new pane left | l = side-by-side, new pane right
      # j = stacked, new pane below   | k = stacked, new pane above
      keybind = super+shift+h=new_split:left
      keybind = super+shift+l=new_split:right
      keybind = super+shift+j=new_split:down
      keybind = super+shift+k=new_split:up

      # Navigate splits — performable: falls through to app when only one pane
      keybind = performable:super+h=goto_split:left
      keybind = performable:super+l=goto_split:right
      keybind = performable:super+j=goto_split:down
      keybind = performable:super+k=goto_split:up

      # Resize splits (no repeat in Ghostty; larger step to compensate)
      keybind = performable:super+alt+h=resize_split:left,20
      keybind = performable:super+alt+l=resize_split:right,20
      keybind = performable:super+alt+j=resize_split:down,20
      keybind = performable:super+alt+k=resize_split:up,20

      # Zoom (like tmux prefix z) + close pane (like tmux C-a x)
      keybind = super+shift+enter=toggle_split_zoom
      keybind = super+shift+x=close_surface

      # -- Oh-My-Pi
      # keybind = alt+backspace=text:\x1b\x7f
      # keybind = alt+enter=text:\n
    '';
  };
}
