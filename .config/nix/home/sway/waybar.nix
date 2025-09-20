
{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    style = ''
      * {
        font-family: "JetBrains Mono";
        font-size: 14px;
      }

      window#waybar {
        background-color: #282828;
        color: #ebdbb2;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #ebdbb2;
      }

      #workspaces button.focused {
        background-color: #458588;
      }

      #clock, #network {
        padding: 0 10px;
      }
    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "sway/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "network" ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };

        clock = {
          format = "{:%H:%M}";
          tooltip-format = "<big>{:%Y-%m-%d}</big>";
        };

        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
          format-disconnected = "Disconnected ⚠";
        };
      };
    };
  };
}
