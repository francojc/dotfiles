{
  config,
  pkgs,
  theme,
  ...
}: {
  # This is intentionally a compact POC, rather than a port of Omarchy.
  # It owns the keyboard-first Hyprland workflow and starts Quickshell's bar.
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      "$mod" = "SUPER";
      monitor = [",preferred,auto,1"];

      input = {
        kb_layout = "us";
        kb_options = "ctrl:nocaps";
        follow_mouse = 1;
        touchpad.natural_scroll = false;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgb(${builtins.substring 1 6 theme.colors.accent}) rgb(${builtins.substring 1 6 theme.colors.blue}) 45deg";
        "col.inactive_border" = "rgb(${builtins.substring 1 6 theme.colors.bg3})";
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        blur.enabled = true;
        shadow.enabled = true;
      };

      animations = {
        enabled = true;
        animation = [
          "windows, 1, 4, default"
          "workspaces, 1, 3, default"
        ];
      };

      bind = [
        "$mod, Return, exec, ghostty"
        "$mod, Space, exec, fuzzel"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        "$mod, L, exec, hyprlock"
        "$mod, Left, movefocus, l"
        "$mod, Right, movefocus, r"
        "$mod, Up, movefocus, u"
        "$mod, Down, movefocus, d"
        "$mod SHIFT, Left, movewindow, l"
        "$mod SHIFT, Right, movewindow, r"
        "$mod SHIFT, Up, movewindow, u"
        "$mod SHIFT, Down, movewindow, d"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
      ];

      bindl = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      exec-once = [
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "nm-applet --indicator"
        "swaync"
        "qs -p ${config.xdg.configHome}/quickshell"
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  xdg.configFile."quickshell/shell.qml".text = ''
    import Quickshell
    import Quickshell.Hyprland
    import Quickshell.Io
    import QtQuick

    Scope {
      SystemClock {
        id: clock
        precision: SystemClock.Minutes
      }

      // Example calls: `qs ipc call bar workspace 2` and `qs ipc call bar toggle`.
      IpcHandler {
        target: "bar"

        function workspace(id: int): void {
          Hyprland.dispatch("workspace " + id)
        }

        function toggle(): void {
          panel.visible = !panel.visible
        }
      }

      PanelWindow {
        id: panel
        anchors {
          top: true
          left: true
          right: true
        }
        implicitHeight: 34
        color: "#${builtins.substring 1 6 theme.colors.bg0}"

        Rectangle {
          anchors.fill: parent
          color: "#${builtins.substring 1 6 theme.colors.bg0}"
          border.color: "#${builtins.substring 1 6 theme.colors.accent}"
          border.width: 1

          Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Repeater {
              model: Hyprland.workspaces

              delegate: Text {
                required property var modelData
                color: modelData.focused ? "#${builtins.substring 1 6 theme.colors.accent}" : modelData.active ? "#${builtins.substring 1 6 theme.colors.fg0}" : "#${builtins.substring 1 6 theme.colors.fg3}"
                text: modelData.name

                MouseArea {
                  anchors.fill: parent
                  onClicked: modelData.activate()
                }
              }
            }
          }

          Text {
            anchors.centerIn: parent
            color: "#${builtins.substring 1 6 theme.colors.fg1}"
            text: Hyprland.focusedWorkspace ? "Hyprland · " + Hyprland.focusedWorkspace.name : "Hyprland · Quickshell · aarch64"
          }

          Text {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            color: "#${builtins.substring 1 6 theme.colors.fg1}"
            text: Qt.formatDateTime(clock.date, "ddd HH:mm")
          }
        }
      }
    }
  '';
}
