{
  config,
  lib,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Basic monitor configuration
      monitor = [
        ",preferred,auto,auto"
      ];

      # Essential input settings
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
      };

      # Minimal general settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Basic decoration
      decoration = {
        rounding = 5;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      # Simple animations
      animations = {
        enabled = true;
        animation = [
          "windows, 1, 7, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Basic keybindings
      "$mod" = "SUPER";

      bind = [
        # Window management
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, V, togglefloating"
        "$mod, F, fullscreen"

        # Applications
        "$mod, Return, exec, kitty"
        "$mod, Space, exec, wofi --show drun"
        "$mod, E, exec, nautilus"

        # Screenshots
        "$mod SHIFT, S, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot.png"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"

        # Move windows to workspaces
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"

        # Window focus
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Volume and brightness
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Essential startup applications
      exec-once = [
        "waybar"
        "mako"
      ];
    };
  };

  # Minimal Waybar
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = ["hyprland/workspaces"];
        modules-center = ["hyprland/window"];
        modules-right = ["pulseaudio" "battery" "clock"];

        "hyprland/workspaces" = {
          disable-scroll = true;
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d}";
        };

        battery = {
          format = "{capacity}% {icon}";
          format-icons = ["" "" "" "" ""];
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "";
          format-icons = ["" "" ""];
          on-click = "pavucontrol";
        };
      };
    };
  };

  # Simple Mako notifications
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
    };
  };

  # Essential packages
  home.packages = with pkgs; [
    wofi
    grim
    slurp
  ];
}

