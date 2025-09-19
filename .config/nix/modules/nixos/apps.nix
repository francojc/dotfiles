{
  pkgs,
  lib,
  ...
}: {
  # System Services
  services.tailscale.enable = true;
  # services.ollama.enable = true;

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
      "app.zen_browser.zen" # Privacy-focused browser
      "org.chromium.Chromium" # Chromium browser
      "com.geekbench.Geekbench6" # System benchmarking

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
    uninstallUnmanaged = false; # Set to true for strict management
  };

  # NixOS System Packages (complementary to Flatpak packages)
  environment.systemPackages = with pkgs; [
    # Development tools
    gcc
    ghostty

    # System utilities
    dconf-editor
    dconf2nix
    pinentry-tty

    # Clipboard tools (Wayland and X11 compatibility)
    wl-clipboard
    xclip

    # Additional Wayland utilities
    wayland-utils
    wlr-randr
  ];

  # Programs
  programs.dconf.enable = true;
}
