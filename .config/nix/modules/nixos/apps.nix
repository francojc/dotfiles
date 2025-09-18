{pkgs, lib, ...}: {
  # System Services
  services.tailscale.enable = true;
  # services.ollama.enable = true;

  # Flatpak Configuration (mirrors homebrew structure from darwin/apps.nix)
  services.flatpak = {
    enable = true;

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
      "com.github.IsmaelMartinez.teams_for_linux" # Microsoft Teams
      "org.mozilla.firefox" # Web browser
      "com.google.Chrome" # Chrome browser
      "com.brave.Browser" # Brave browser
      "org.chromium.Chromium" # Chromium browser

      # Communication
      "com.discordapp.Discord" # Discord
      "org.signal.Signal" # Signal messenger
      "com.slack.Slack" # Slack
      "us.zoom.Zoom" # Zoom

      # Media & Entertainment
      "com.spotify.Client" # Spotify
      "org.videolan.VLC" # VLC media player
      "org.kde.kdenlive" # Video editor
      "org.audacityteam.Audacity" # Audio editor
      "fr.handbrake.ghb" # HandBrake video converter

      # Productivity
      "md.obsidian.Obsidian" # Note taking
      "org.zotero.Zotero" # Reference manager
      "org.libreoffice.LibreOffice" # Office suite
      "org.gnome.TextEditor" # Text editor

      # Graphics & Design
      "org.gimp.GIMP" # Image editor
      "org.inkscape.Inkscape" # Vector graphics
      "org.blender.Blender" # 3D modeling

      # System Tools
      "org.gnome.FileRoller" # Archive manager
      "org.gnome.baobab" # Disk usage analyzer
      "org.gnome.DiskUtility" # Disk utility

      # File Management
      "org.gnome.Nautilus" # File manager
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
