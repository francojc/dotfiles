{
  hostname,
  theme,
  isDarwin,
  ...
}: {
  xdg.configFile."kitty/kitty.conf" = {
    text = ''
      # ~/.config/kitty/kitty.conf
      # Managed by Nix - see ~/.dotfiles/.config/nix/home/kitty.nix

      # System and Remote Control ----------------------------
      ## Remote Access
      allow_remote_control yes
      listen_on unix:/tmp/nicekitty
      macos_quit_when_last_window_closed yes

      # Font Configuration ------------------------------------
      ## Primary Font Settings
      font_family      family="JetBrainsMono Nerd Font Mono"
      bold_font        auto
      italic_font      auto
      bold_italic_font auto

      font_size ${toString (
        if hostname == "Mac-Minicore"
        then 20
        else if hostname == "Macbook-Airborne"
        then 16
        else 14
      )}

      ## Advanced Font Rendering
      modify_font cell_width 100%
      modify_font cell_height 1px

      # Text Rendering -----------------------------------------
      ## Drawing and Composition
      box_drawing_scale 0.001, 0.85, 1, 1.5
      text_composition_strategy 1.0 0
      text_fg_override_threshold 3

      # Performance Tuning -------------------------------------
      input_delay 2
      sync_to_monitor no

      # Visual Appearance --------------------------------------
      ## Theme Colors (Generated from Nix theme: ${theme.name})
      background ${theme.colors.bg0}
      foreground ${theme.colors.fg0}
      selection_background ${theme.colors.bg3}
      selection_foreground ${theme.colors.fg0}
      url_color ${theme.colors.aqua}
      cursor ${theme.colors.cursor}
      cursor_text_color ${theme.colors.bg0}

      # Tabs
      active_tab_background ${theme.colors.accent}
      active_tab_foreground ${theme.colors.bg0}
      inactive_tab_background ${theme.colors.bg2}
      inactive_tab_foreground ${theme.colors.fg3}

      # Windows
      active_border_color ${theme.colors.accent}
      inactive_border_color ${theme.colors.bg2}

      # Normal colors
      color0 ${theme.colors.bg0}
      color1 ${theme.colors.red}
      color2 ${theme.colors.green}
      color3 ${theme.colors.yellow}
      color4 ${theme.colors.blue}
      color5 ${theme.colors.purple}
      color6 ${theme.colors.aqua}
      color7 ${theme.colors.fg1}

      # Bright colors
      color8 ${theme.colors.bg3}
      color9 ${theme.colors.bright_red}
      color10 ${theme.colors.bright_green}
      color11 ${theme.colors.bright_yellow}
      color12 ${theme.colors.bright_blue}
      color13 ${theme.colors.bright_purple}
      color14 ${theme.colors.bright_aqua}
      color15 ${theme.colors.fg0}

      # Extended colors
      color16 ${theme.colors.orange}
      color17 ${theme.colors.bright_orange}

      ## Transparency and Opacity
      background_opacity 1.0

      ## Cursor Styling
      cursor_shape beam
      cursor_blink_interval -1
      cursor_trail 6

      ## Color and Border Settings
      window_border_width 1pt
      inactive_text_alpha .50

      # User Experience ----------------------------------------
      ## Interaction Preferences
      mouse_hide_wait 3.0
      copy_on_select clipboard

      ## Feedback Mechanisms
      enable_audio_bell yes
      visual_bell_duration 0.25
      bell_on_tab " "

      # Window Management (Minimal - Tmux handles most) --------
      initial_window_width 600
      initial_window_height 600
      draw_minimal_borders yes
      window_padding_width 2 2 0 2
      placement_strategy center
      hide_window_decorations titlebar-only
      macos_show_window_title_in none

      # Tab Management (Minimal - Tmux handles windows/tabs) ---
      # Kitty's tabs are not used when running Tmux.
      tab_bar_edge top
      tab_bar_style hidden
      tab_bar_align right
      tab_bar_min_tabs 1
      tab_powerline_style slanted
      active_tab_font_style bold
      inactive_tab_font_style bold
      tab_title_template "{fmt.fg.tab}{title}"
      tab_title_max_length 0

      # System Notifications (Minimal - Tmux handles activity) -
      # Kitty's notifications are less relevant when Tmux is managing sessions.
      notify_on_cmd_finish unfocused 10.0 notify

      # Key Mappings (Minimal - Tmux handles most) -------------
      # Only include keymaps that are specific to the terminal emulator itself,
      # like clipboard operations that might be handled by the terminal.

      ## Clipboard Operations
      map cmd+c copy_to_clipboard
      map cmd+v paste_from_clipboard

      ## Configuration (Kitty specific)
      map cmd+, edit_config_file
      map ctrl+cmd+, load_config_file

      # All other keybindings related to window/pane/session management
      # should be configured in ~/.tmux.conf
    '';
  };
}
