{pkgs, ...}: {
  # Minimal, Wayland-native base for the Parallels aarch64 lab.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.hyprlock.enable = true;
  security.pam.services.hyprlock = {};

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config.common.default = "hyprland;gtk";
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
      user = "greeter";
    };
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    cliphist
    fuzzel
    grim
    hyprpaper
    libnotify
    networkmanagerapplet
    pavucontrol
    playerctl
    quickshell
    slurp
    swappy
    swaynotificationcenter
    wayland-utils
    wf-recorder
    wl-clipboard
  ];
}
