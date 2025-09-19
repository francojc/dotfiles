{
  pkgs,
  lib,
  username,
  ...
}: {
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Display Manager - using SDDM for better Wayland support
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin = {
      enable = true;
      user = username;
    };
  };

  # XDG Portal for Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # Security for Hyprland
  security = {
    polkit.enable = true;
    pam.services.swaylock = {};
  };

  # Essential Wayland packages
  environment.systemPackages = with pkgs; [
    # Core Wayland tools
    wayland
    wayland-protocols
    wayland-utils
    wl-clipboard
    wlr-randr

    # Hyprland ecosystem
    hyprpaper
    hypridle
    hyprlock
    hyprpicker

    # Application launcher and bar
    wofi
    waybar

    # Notifications
    mako
    libnotify

    # Screenshot tools
    grim
    slurp

    # File manager and terminal
    nautilus
    ghostty

    # System utilities
    brightnessctl
    playerctl
    pamixer

    # Polkit agent
    polkit_gnome
  ];

  # Fonts for better UI rendering
  fonts.packages = with pkgs; [
    font-awesome
    material-design-icons
  ];

  # Session variables for Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  # Workaround for autologin with SDDM
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}