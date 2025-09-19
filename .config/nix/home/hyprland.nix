{
  config,
  lib,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Monitor configuration
      monitor = [
        # Virtual-1 (current display) - use widescreen resolution
        "Virtual-1,1920x1080@60,0x0,1"
        # MacBook Pro retina display (when available)
        ",2560x1600@59.99,0x0,1.5"
        # Fallback for any unrecognized monitors
        ",preferred,auto,1"
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        kb_options = "terminate:ctrl_alt_bksp,lv3:ralt_switch";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          disable_while_typing = true;
        };

        sensitivity = 0;
      };

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";
        allow_tearing = false;
      };

      # Decoration
      decoration = {
        rounding = 8;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      # Animations
      animations = {
        enabled = true;

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Layout configuration
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_is_master = true;
      };

      # Gestures
      gestures = {
        workspace_swipe = true;
      };

      # Miscellaneous
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        # Optimize for high-DPI displays
        vfr = true;
        vrr = 1;
      };

      # Keybindings (Mac-like, ported from dconf)
      "$mod" = "SUPER";

      bind = [
        # Core Mac window management
        "$mod, W, killactive"                           # Cmd+W (close window)
        "$mod, M, fullscreen, 1"                        # Cmd+M (maximize)
        "$mod, Q, exit"                                 # Cmd+Q (quit Hyprland)
        "$mod, H, exec, hyprctl dispatch workspace empty" # Cmd+H (hide/minimize)

        # Mac application shortcuts
        "$mod, Space, exec, wofi --show drun"           # Cmd+Space (Spotlight)
        "$mod, T, exec, ghostty"                          # Cmd+T (new terminal)
        "$mod, N, exec, ghostty"                          # Cmd+N (new window)
        "$mod, Return, exec, ghostty"                     # Cmd+Enter (terminal)

        # File management
        "$mod SHIFT, N, exec, nautilus"                 # Cmd+Shift+N (new finder window)
        "$mod, E, exec, nautilus"                       # Cmd+E (file manager)

        # Mac screenshots
        "$mod SHIFT, 3, exec, grim ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png"        # Cmd+Shift+3 (full screen)
        "$mod SHIFT, 4, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +'%Y%m%d-%H%M%S').png"  # Cmd+Shift+4 (selection)
        "$mod SHIFT, 5, exec, grim -g \"$(slurp)\" - | wl-copy"                               # Cmd+Shift+5 (to clipboard)

        # Mission Control / Spaces (Mac workspaces)
        "$mod, UP, exec, hyprctl dispatch overview"     # Cmd+Up (Mission Control-like)
        "$mod, F3, exec, hyprctl dispatch overview"     # F3 (Mission Control)

        # Workspace switching (Mac Spaces style)
        "CTRL, left, workspace, e-1"                    # Ctrl+Left (previous space)
        "CTRL, right, workspace, e+1"                   # Ctrl+Right (next space)
        "$mod, 1, workspace, 1"                         # Cmd+1-9 (direct space access)
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move windows between spaces
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Window cycling (Mac-style)
        "$mod, grave, cyclenext"                        # Cmd+` (cycle through windows of same app)
        "$mod SHIFT, grave, cyclenext, prev"
        "$mod, Tab, exec, hyprctl dispatch focuscurrentorlast" # Cmd+Tab (last window)

        # Mac-like window management
        "$mod, F, fullscreen, 0"                        # Cmd+F (fullscreen)
        "$mod SHIFT, F, togglefloating"                 # Cmd+Shift+F (floating)

        # System controls
        "$mod, comma, exec, gnome-control-center"       # Cmd+, (preferences)
        "$mod SHIFT, Q, exec, wlogout"                  # Cmd+Shift+Q (logout)

        # Hardware controls (MacBook specific)
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"

        # Media controls
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        # Alternative window focus (for when needed)
        "ALT, H, movefocus, l"                          # Alt+H/J/K/L for vim-like movement
        "ALT, J, movefocus, d"
        "ALT, K, movefocus, u"
        "ALT, L, movefocus, r"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Window rules
      windowrule = [
        "float, ^(pavucontrol)$"
        "float, ^(nm-connection-editor)$"
        "float, ^(blueman-manager)$"
        "float, ^(org.gnome.Settings)$"
        "float, ^(org.gnome.design.Palette)$"
        "float, ^(Color Picker)$"
        "float, ^(Network)$"
        "float, ^(xdg-desktop-portal)$"
        "float, ^(xdg-desktop-portal-gnome)$"
        "float, ^(transmission-gtk)$"
      ];

      # Startup applications
      exec-once = [
        "waybar"
        "mako"
        "hyprpaper"
        "/nix/store/*/libexec/polkit-gnome-authentication-agent-1"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];
    };
  };

  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;

        modules-left = ["hyprland/workspaces" "hyprland/mode" "hyprland/scratchpad"];
        modules-center = ["hyprland/window"];
        modules-right = ["idle_inhibitor" "pulseaudio" "network" "cpu" "memory" "temperature" "backlight" "battery" "clock" "tray"];

        # Module configurations
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          warp-on-scroll = false;
          format = "{name}: {icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            urgent = "";
            focused = "";
            default = "";
          };
        };

        clock = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
        };

        cpu = {
          format = "{usage}% ";
          tooltip = false;
        };

        memory = {
          format = "{}% ";
        };

        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = ["" "" ""];
        };

        backlight = {
          format = "{percent}% {icon}";
          format-icons = ["" "" "" "" "" "" "" "" ""];
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = ["" "" "" "" ""];
        };

        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };

        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "FiraCode Nerd Font";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(43, 48, 59, 0.8);
        border-bottom: 3px solid rgba(100, 114, 125, 0.5);
        color: #ffffff;
        transition-property: background-color;
        transition-duration: .5s;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #ffffff;
        border-bottom: 3px solid transparent;
      }

      #workspaces button:hover {
        background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.focused {
        background-color: #64727D;
        border-bottom: 3px solid #ffffff;
      }

      #workspaces button.urgent {
        background-color: #eb4d4b;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #tray {
        padding: 0 10px;
        color: #ffffff;
      }
    '';
  };

  # Mako notification daemon
  services.mako = {
    enable = true;
    settings = {
      background-color = "#2e3440";
      border-color = "#88c0d0";
      border-radius = 8;
      border-size = 2;
      text-color = "#eceff4";
      font = "FiraCode Nerd Font 11";
      default-timeout = 5000;
      ignore-timeout = true;
    };
  };

  # Hyprpaper for wallpapers
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/Pictures/wallpaper.jpg"
      ];
      wallpaper = [
        ",~/Pictures/wallpaper.jpg"
      ];
    };
  };

  # Additional home packages for Hyprland
  home.packages = with pkgs; [
    cliphist
    wlogout
    swayidle
    swaylock-effects
  ];
}
