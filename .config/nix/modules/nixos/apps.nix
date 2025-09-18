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

      # Communication
      # "org.signal.Signal" # Signal messenger - not available in Flathub
      "us.zoom.Zoom" # Zoom

      # Media & Entertainment
      "com.spotify.Client" # Spotify
      "org.videolan.VLC" # VLC media player
      "org.audacityteam.Audacity" # Audio editor
      "fr.handbrake.ghb" # HandBrake video converter

      # Productivity
      "md.obsidian.Obsidian" # Note taking
      "org.zotero.Zotero" # Reference manager

      # System Tools
      # "org.gnome.FileRoller" # Archive manager
      # "org.gnome.baobab" # Disk usage analyzer
      # "org.gnome.DiskUtility" # Disk utility

      # File Management
      # "org.gnome.Nautilus" # File manager
      "com.dropbox.Client" # Dropbox
    ];

    # Uninstall packages not managed by nix-flatpak
    uninstallUnmanaged = false; # Set to true for strict management
  };

  # NixOS System Packages (complementary to Flatpak packages)
  environment.systemPackages = with pkgs; [
    dconf-editor
    dconf2nix
    gcc
    ghostty
    gnome-tweaks
    gnomeExtensions.awesome-tiles
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.extension-list
    pinentry-tty
    wl-clipboard
    xclip
  ];

  # Programs
  programs.dconf.enable = true;
}
