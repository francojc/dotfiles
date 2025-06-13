{pkgs, ...}: {
  # enable tailscale for nixos hosts
  # (macOS hosts use the tailscale app from the official website)
  services.tailscale.enable = true;

  # Add NixOS system packages (complementary to Home Manager packages)
  environment.systemPackages = with pkgs; [
    dconf2nix
    ghostty
    gnome-tweaks
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.extension-list
    gnomeExtensions.awesome-tiles
    xclip
    wl-clipboard
  ];
}
