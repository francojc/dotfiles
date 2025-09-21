{
  config,
  lib,
  pkgs,
  ...
}: {
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;

    config = {
      modifier = "Mod4"; # Use Super/Windows key as modifier

      # Key bindings
      keybindings = lib.mkOptionDefault {
        # Terminal
        "Mod4+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        # Application launcher
        "Mod4+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        # File manager
        "Mod4+e" = "exec ${pkgs.pcmanfm}/bin/pcmanfm";
        # Firefox
        "Mod4+f" = "exec ${pkgs.firefox}/bin/firefox";
        # Screenshot
        "Print" = "exec ${pkgs.flameshot}/bin/flameshot gui";
        # Volume controls
        "XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
      };

      # Status bar configuration
      bars = [
        {
          position = "bottom";
          statusCommand = "${pkgs.i3status}/bin/i3status";
          colors = {
            background = "#2f2f2f";
            statusline = "#ffffff";
            separator = "#666666";
            focusedWorkspace = {
              border = "#4c7899";
              background = "#285577";
              text = "#ffffff";
            };
            activeWorkspace = {
              border = "#333333";
              background = "#5f676a";
              text = "#ffffff";
            };
            inactiveWorkspace = {
              border = "#333333";
              background = "#222222";
              text = "#888888";
            };
            urgentWorkspace = {
              border = "#2f343a";
              background = "#900000";
              text = "#ffffff";
            };
          };
        }
      ];

      # Window settings
      window = {
        border = 2;
        titlebar = false;
      };

      # Startup applications
      startup = [
        {
          command = "${pkgs.feh}/bin/feh --bg-scale ~/.config/wallpaper.jpg || ${pkgs.feh}/bin/feh --bg-fill /run/current-system/sw/share/pixmaps/nixos-logo.png";
          always = false;
          notification = false;
        }
        {
          command = "${pkgs.networkmanagerapplet}/bin/nm-applet";
          always = false;
          notification = false;
        }
      ];

      # Workspace names
      workspaceOutputAssign = [
        {
          workspace = "1";
          output = "primary";
        }
      ];
    };
  };

  # i3status configuration
  programs.i3status = {
    enable = true;
    general = {
      colors = true;
      interval = 5;
      color_good = "#a3be8c";
      color_bad = "#bf616a";
      color_degraded = "#d08770";
    };
    modules = {
      "wireless _first_" = {
        position = 1;
        settings = {
          format_up = "W: (%quality at %essid) %ip";
          format_down = "W: down";
        };
      };
      "ethernet _first_" = {
        position = 2;
        settings = {
          format_up = "E: %ip (%speed)";
          format_down = "E: down";
        };
      };
      "battery all" = {
        position = 3;
        settings = {
          format = "%status %percentage %remaining";
          format_down = "No battery";
          status_chr = "⚡ CHR";
          status_bat = "🔋 BAT";
          status_unk = "? UNK";
          status_full = "☻ FULL";
          path = "/sys/class/power_supply/BAT%d/uevent";
          low_threshold = 10;
        };
      };
      "volume master" = {
        position = 4;
        settings = {
          format = "♪: %volume";
          format_muted = "♪: muted (%volume)";
          device = "default";
          mixer = "Master";
          mixer_idx = 0;
        };
      };
      "load" = {
        position = 5;
        settings = {
          format = "Load: %1min";
        };
      };
      "tztime local" = {
        position = 6;
        settings = {
          format = "%Y-%m-%d %H:%M:%S";
        };
      };
    };
  };
}