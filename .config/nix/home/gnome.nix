{lib, ...}: {
  dconf.settings = {
    # --- Keyboard ---
    "org/gnome/desktop/input-sources" = {
      xkb-options = ["ctrl:nocaps"];
    };

    # --- Mouse & Touchpad ---
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = true;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      tap-to-click = true;
    };

    # --- Interface ---
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-show-weekday = true;
      clock-format = "24h";
      enable-hot-corners = false;
      monospace-font-name = "JetBrainsMono Nerd Font Mono 12";
    };

    # --- Window Management ---
    "org/gnome/mutter" = {
      center-new-windows = true;
      edge-tiling = true;
      dynamic-workspaces = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
      focus-mode = "click";
    };

    # --- Power (prevent sleep on AC – useful for a headless-ish Mac Mini) ---
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 900;
    };
  };
}
