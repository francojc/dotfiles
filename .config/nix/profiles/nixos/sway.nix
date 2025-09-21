{
  pkgs,
  ...
}: {
  # --- Flatpak Support ---
  services.flatpak.enable = true;

  # XDG portal for Flatpak integration with Wayland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
    ];
    config.common.default = "*";
  };

  # --- Sway Window Manager ---
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk apps have a uniform theme
  };

  # Add sway and related packages to the environment
  environment.systemPackages = with pkgs; [
    sway
    waybar
    wofi
  ];
}