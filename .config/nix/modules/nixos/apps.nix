{
  pkgs,
  lib,
  ...
}: {
  # System Services
  services.tailscale.enable = true;

  # Flatpak Configuration (mirrors homebrew structure from darwin/apps.nix)
  services.flatpak = {
    enable = true;

    # Auto-update Flatpak packages on activation
    update.onActivation = true;

    # Remotes (equivalent to homebrew.taps)
    remotes = lib.mkOptionDefault [
      {
        name = "flathub-beta";
        location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      }
    ];

    # Packages (equivalent to homebrew.brews + homebrew.casks)
    packages = [
      # Development Tools
      # -- Find a list of Flatpak package IDs at https://flathub.org/apps
      # -- Get package IDs using the command: flatpak search <package_name> | awk '{print $1}'
      # "app.zen_browser.zen" # Privacy-focused browser
      "org.chromium.Chromium" # Chromium browser
      "com.geekbench.Geekbench6" # System benchmarking
      "page.tesk.Refine" # Gnome tweaks

      # Communication

      # Media & Entertainment
      # "org.videolan.VLC" # VLC media player

      # Productivity
      # "md.obsidian.Obsidian" # Note taking
      # "org.zotero.Zotero" # Reference manager

      # System Tools
      # "org.gnome.FileRoller" # Archive manager
      # "org.gnome.baobab" # Disk usage analyzer
      # "org.gnome.DiskUtility" # Disk utility

      # File Management
      # "org.gnome.Nautilus" # File manager
      # "com.dropbox.Client" # Dropbox
    ];

    # Uninstall packages not managed by nix-flatpak
    uninstallUnmanaged = true; # Set to true for strict management
  };

  # NixOS System Packages (complementary to Flatpak packages)
  environment.systemPackages = with pkgs;
    [
      coreutils # GNU core utilities
      dconf-editor
      dconf2nix
      gcc
      ghostty
      glibc
      pinentry-tty
      wl-clipboard
      xclip
    ]
    # These GNOME helpers are optional because the Quattro guest is a
    # Hyprland-only aarch64 system, and not every extension is built there.
    ++ lib.optional (builtins.hasAttr "gnome-extensions-manager" pkgs) gnome-extensions-manager
    ++ lib.optional (builtins.hasAttr "gnome-tweaks" pkgs) gnome-tweaks
    ++ lib.optional (builtins.hasAttr "paperwm" gnomeExtensions) gnomeExtensions.paperwm
    ++ lib.optional (builtins.hasAttr "clipboard-indicator" gnomeExtensions) gnomeExtensions.clipboard-indicator
    ++ lib.optional (builtins.hasAttr "extension-list" gnomeExtensions) gnomeExtensions.extension-list;

  # Programs
  programs.dconf.enable = true;
}
