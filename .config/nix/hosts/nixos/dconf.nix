# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
# Modified to include Mac-like keybindings
{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    # Your existing Console settings
    "org/gnome/Console" = {
      font-scale = 1.2000000000000002;
      last-window-maximised = true;
      last-window-size = mkTuple [1024 736];
    };

    "org/gnome/Extensions" = {
      window-height = 625;
      window-width = 496;
    };

    "org/gnome/Geary" = {
      migrated-config = true;
      window-maximize = true;
    };

    "org/gnome/Music" = {
      window-maximized = true;
    };

    "org/gnome/calendar" = {
      active-view = "month";
      window-maximized = true;
      window-size = mkTuple [768 600];
    };

    "org/gnome/control-center" = {
      last-panel = "display";
      window-state = mkTuple [980 640 true];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = ["Utilities" "YaST" "Pardus"];
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = ["X-Pardus-Apps"];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = ["org.freedesktop.GnomeAbrt.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.font-viewer.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop"];
      categories = ["X-GNOME-Utilities"];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = ["X-SuSE-YaST"];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      primary-color = "#3a4ba0";
      secondary-color = "#2f302f";
    };

    # Updated input sources to include Alt/Super key swap for Mac-like behavior
    "org/gnome/desktop/input-sources" = {
      sources = [(mkTuple ["xkb" "us"])];
      xkb-options = ["terminate:ctrl_alt_bksp" "lv3:ralt_switch" "altwin:swap_lalt_lwin"];
    };

    # Merge with your existing interface settings + Mac-like additions
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-animations = true;
      font-hinting = "slight";
      icon-theme = "Adwaita";
      text-scaling-factor = 0.95;
      show-battery-percentage = true;
      clock-show-weekday = true;
    };

    "org/gnome/desktop/notifications" = {
      application-children = ["firefox" "gnome-power-panel" "org-gnome-geary" "org-gnome-settings" "gnome-printers-panel"];
    };

    "org/gnome/desktop/notifications/application/brave-browser" = {
      enable = false;
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-printers-panel" = {
      application-id = "gnome-printers-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-geary" = {
      application-id = "org.gnome.Geary.desktop";
      enable = false;
    };

    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = false;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "default";
      natural-scroll = false;
    };

    # Updated touchpad settings for Mac-like behavior
    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
      natural-scroll = true;
      tap-to-click = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///nix/store/6mmxqwrgm4yfima3whs57dvn1spg1bcf-simple-blue-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
      primary-color = "#3a4ba0";
      secondary-color = "#2f302f";
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = ["org.gnome.Settings.desktop" "org.gnome.Contacts.desktop" "org.gnome.Nautilus.desktop"];
    };

    # NEW: Window management keybindings (Mac-like)
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>w"];
      minimize = ["<Super>m"];
      toggle-maximized = ["<Super>f"];
      show-desktop = ["<Super>d"];

      # Workspace switching
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];

      # Move windows between workspaces
      move-to-workspace-1 = ["<Super><Shift>1"];
      move-to-workspace-2 = ["<Super><Shift>2"];
      move-to-workspace-3 = ["<Super><Shift>3"];
      move-to-workspace-4 = ["<Super><Shift>4"];

      # Window cycling
      cycle-windows = ["<Super>grave"]; # Super+`
      cycle-windows-backward = ["<Super><Shift>grave"];
    };

    "org/gnome/epiphany/state" = {
      is-maximized = false;
      window-size = mkTuple [1024 735];
    };

    "org/gnome/epiphany/web" = {
      default-zoom-level = 1.0;
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/gnome-system-monitor" = {
      cpu-stacked-area-chart = true;
      current-tab = "processes";
      maximized = false;
      show-dependencies = false;
      show-whose-processes = "user";
      window-height = 720;
      window-width = 800;
    };

    "org/gnome/gnome-system-monitor/proctree" = {
      col-26-visible = false;
      col-26-width = 0;
      columns-order = [0 12 1 2 3 4 6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 22 23 24 25 26];
      sort-col = 8;
      sort-order = 0;
    };

    "org/gnome/maps" = {
      last-viewed-location = [36.0998131 (-80.2440518)];
      map-type = "MapsVectorSource";
      transportation-type = "pedestrian";
      window-maximized = true;
      zoom-level = 10;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
    };

    "org/gnome/nautilus/list-view" = {
      default-zoom-level = "small";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [890 550];
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-schedule-automatic = false;
    };

    # NEW: Media keys and system shortcuts (Mac-like)
    "org/gnome/settings-daemon/plugins/media-keys" = {
      terminal = ["<Super>Return"];
      home = ["<Super>e"]; # File manager

      # Screenshot shortcuts (Mac-like)
      screenshot = ["<Super><Shift>3"];
      area-screenshot = ["<Super><Shift>4"];
      window-screenshot = ["<Super><Shift>5"];

      # Custom keybindings
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    # NEW: Custom application shortcuts
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      command = "gnome-console"; # Using GNOME Console since you have it configured
      binding = "<Super>t";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "File Manager";
      command = "nautilus";
      binding = "<Super><Shift>f";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = ["windowsNavigator@gnome-shell-extensions.gcampax.github.com" "dash-to-dock@micxgx.gmail.com" "auto-move-windows@gnome-shell-extensions.gcampax.github.com" "launch-new-instance@gnome-shell-extensions.gcampax.github.com" "light-style@gnome-shell-extensions.gcampax.github.com" "native-window-placement@gnome-shell-extensions.gcampax.github.com" "drive-menu@gnome-shell-extensions.gcampax.github.com" "status-icons@gnome-shell-extensions.gcampax.github.com"];
      enabled-extensions = ["clipboard-indicator@tudmotu.com" "system-monitor@gnome-shell-extensions.gcampax.github.com" "window-list@gnome-shell-extensions.gcampax.github.com" "apps-menu@gnome-shell-extensions.gcampax.github.com" "places-menu@gnome-shell-extensions.gcampax.github.com" "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com" "awesome-tiles@velitasali.com" "extension-list@tu.berry"];
      favorite-apps = [];
      last-selected-power-profile = "power-saver";
      welcome-dialog-last-shown-version = "47.2";
    };

    # NEW: GNOME Shell keybindings (Mac-like)
    "org/gnome/shell/keybindings" = {
      toggle-overview = ["<Super>space"];
      show-applications = ["<Super>a"];
      toggle-message-tray = []; # Disable to avoid conflicts
    };

    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [];
    };

    # Your existing awesome-tiles configuration (preserved)
    "org/gnome/shell/extensions/awesome-tiles" = {
      enable-inner-gaps = true;
      gap-size = 0;
      gap-size-increments = 3;
      next-step-timeout = 1000;
      shortcut-align-window-to-center = [];
      shortcut-decrease-gap-size = [];
      shortcut-increase-gap-size = [];
      shortcut-tile-window-to-bottom = ["<Shift><Super>j"];
      shortcut-tile-window-to-bottom-left = [];
      shortcut-tile-window-to-bottom-right = [];
      shortcut-tile-window-to-center = ["<Shift><Super>m"];
      shortcut-tile-window-to-left = ["<Shift><Super>h"];
      shortcut-tile-window-to-right = ["<Shift><Super>l"];
      shortcut-tile-window-to-top = ["<Shift><Super>k"];
      shortcut-tile-window-to-top-left = ["<Shift><Alt><Super>h"];
      shortcut-tile-window-to-top-right = ["<Shift><Alt><Super>l"];
      tiling-steps-side = "0.25,0.5,0.75,1,0.75,0.5,0.25,0";
    };

    "org/gnome/shell/extensions/clipboard-indicator" = {
      disable-down-arrow = true;
      strip-text = true;
    };

    "org/gnome/shell/extensions/system-monitor" = {
      show-download = false;
      show-swap = false;
      show-upload = false;
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 157;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [26 23];
      window-size = mkTuple [1231 685];
    };
  };
}
