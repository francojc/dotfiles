{
  hostname,
  theme,
  isDarwin,
  ...
}: {
  xdg.configFile."wezterm/wezterm.lua" = {
    text = ''
      -- ~/.config/wezterm/wezterm.lua
      -- Managed by Nix - see ~/.dotfiles/.config/nix/home/wezterm.nix

      local wezterm = require('wezterm')
      local config = wezterm.config_builder()

      -- Font Configuration ------------------------------------
      config.font = wezterm.font('JetBrainsMono Nerd Font Mono')
      config.font_size = ${toString (
        if hostname == "Mac-Minicore"
        then 20
        else if hostname == "Macbook-Airborne"
        then 16
        else 14
      )}

      -- Theme Colors (Generated from Nix theme: ${theme.name}) --
      config.colors = {
        foreground = '${theme.colors.fg0}',
        background = '${theme.colors.bg0}',

        cursor_bg = '${theme.colors.cursor}',
        cursor_fg = '${theme.colors.bg0}',
        cursor_border = '${theme.colors.cursor}',

        selection_fg = '${theme.colors.fg0}',
        selection_bg = '${theme.colors.bg3}',

        scrollbar_thumb = '${theme.colors.bg3}',
        split = '${theme.colors.bg2}',

        ansi = {
          '${theme.colors.bg0}',
          '${theme.colors.red}',
          '${theme.colors.green}',
          '${theme.colors.yellow}',
          '${theme.colors.blue}',
          '${theme.colors.purple}',
          '${theme.colors.aqua}',
          '${theme.colors.fg1}',
        },

        brights = {
          '${theme.colors.bg3}',
          '${theme.colors.bright_red}',
          '${theme.colors.bright_green}',
          '${theme.colors.bright_yellow}',
          '${theme.colors.bright_blue}',
          '${theme.colors.bright_purple}',
          '${theme.colors.bright_aqua}',
          '${theme.colors.fg0}',
        },

        indexed = {
          [16] = '${theme.colors.orange}',
          [17] = '${theme.colors.bright_orange}',
        },

        tab_bar = {
          background = '${theme.colors.bg0}',

          active_tab = {
            bg_color = '${theme.colors.accent}',
            fg_color = '${theme.colors.bg0}',
            intensity = 'Bold',
          },

          inactive_tab = {
            bg_color = '${theme.colors.bg2}',
            fg_color = '${theme.colors.fg3}',
            intensity = 'Bold',
          },

          inactive_tab_hover = {
            bg_color = '${theme.colors.bg3}',
            fg_color = '${theme.colors.fg1}',
            intensity = 'Bold',
          },

          new_tab = {
            bg_color = '${theme.colors.bg1}',
            fg_color = '${theme.colors.fg2}',
          },

          new_tab_hover = {
            bg_color = '${theme.colors.bg2}',
            fg_color = '${theme.colors.fg1}',
          },
        },
      }

      -- Cursor Styling -----------------------------------------
      config.default_cursor_style = 'BlinkingBar'
      config.cursor_blink_rate = 0  -- Disable blinking
      config.cursor_thickness = '2px'

      -- Window Management (Minimal - Tmux handles most) --------
      config.initial_cols = 80
      config.initial_rows = 40
      config.window_padding = {
        left = 2,
        right = 2,
        top = 0,
        bottom = 2,
      }
      config.window_decorations = 'RESIZE'
      config.window_close_confirmation = 'NeverPrompt'

      -- Visual Appearance --------------------------------------
      config.enable_scroll_bar = false
      config.use_fancy_tab_bar = false
      config.window_frame = {
        font = wezterm.font({ family = 'JetBrainsMono Nerd Font Mono', weight = 'Bold' }),
        font_size = ${toString (
          if hostname == "Mac-Minicore"
          then 18
          else if hostname == "Macbook-Airborne"
          then 14
          else 12
        )},
      }

      -- Window borders
      config.window_background_opacity = 1.0

      -- Inactive pane dimming (approximates Kitty's inactive_text_alpha)
      config.inactive_pane_hsb = {
        saturation = 0.9,
        brightness = 0.5,
      }

      -- Tab Management (Minimal - Tmux handles windows/tabs) ---
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true
      config.tab_bar_at_bottom = false
      config.tab_max_width = 32
      config.use_resize_increments = false

      -- User Experience ----------------------------------------
      config.audible_bell = 'SystemBeep'
      config.visual_bell = {
        fade_in_duration_ms = 125,
        fade_out_duration_ms = 125,
        target = 'CursorColor',
      }

      -- Mouse behavior
      config.mouse_bindings = {
        {
          event = { Up = { streak = 1, button = 'Left' } },
          mods = 'NONE',
          action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor('Clipboard'),
        },
      }

      -- Performance Tuning -------------------------------------
      config.front_end = 'WebGpu'
      config.max_fps = 120
      config.animation_fps = 60

      -- macOS-Specific Settings --------------------------------
      ${
        if isDarwin
        then ''
      config.quit_when_all_windows_are_closed = true
      config.native_macos_fullscreen_mode = false
      config.macos_window_background_blur = 0
        ''
        else ""
      }

      -- Key Mappings (Minimal - Tmux handles most) -------------
      config.keys = {
        -- Clipboard operations
        { key = 'c', mods = 'CMD', action = wezterm.action.CopyTo('Clipboard') },
        { key = 'v', mods = 'CMD', action = wezterm.action.PasteFrom('Clipboard') },

        -- Configuration
        { key = ',', mods = 'CMD', action = wezterm.action.SpawnCommandInNewTab({
          args = { os.getenv('EDITOR') or 'nvim', wezterm.config_file },
        })},
        { key = ',', mods = 'CMD|CTRL', action = wezterm.action.ReloadConfiguration },
      }

      return config
    '';
  };
}
