{pkgs, ...}: {
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4"; # Super key
      terminal = "kitty";
      menu = "wofi --show drun";

      keybindings = {
        "Mod4+Shift+q" = "kill";
        "Mod4+d" = "exec ${pkgs.wofi}/bin/wofi --show drun";
        "Mod4+Return" = "exec kitty";
      };

      bars = []; # Disable the default swaybar
    };
  };
}
