{pkgs, ...}: {
  # Add NixOS system packages (complementary to Home Manager packages)
  environment.systemPackages = with pkgs; [
    # Keep only NixOS-specific system packages here, if any.
    # Example: gnome packages if not pulled in by services.xserver.desktopManager.gnome.enable
    dconf2nix
    gnome-tweaks
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.extension-list
    gnomeExtensions.awesome-tiles
    xclip
  ];
}
