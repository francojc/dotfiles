{
  pkgs,
  lib,
  username,
  ...
}: {
  # Enable Hyprland with minimal setup
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Simple display manager setup
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

  # Essential XDG Portal setup
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # Basic security
  security.polkit.enable = true;

  # Minimal package set for Hyprland
  environment.systemPackages = with pkgs; [
    # Core Wayland tools
    wl-clipboard

    # Basic Hyprland tools
    waybar
    mako
    wofi

    # Screenshot tools
    grim
    slurp

    # Terminal and file manager
    kitty
    nautilus

    # System utilities
    brightnessctl
    pamixer

    # Authentication agent
    polkit_gnome
  ];

  # Essential session variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Workaround for autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}