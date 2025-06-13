{pkgs, ...}: {
  # enable Tailscale for nixos hosts
  # (macOS hosts use the tailscale app from the official website)
  services.tailscale = {
    enable = true;
  };
  # Enable Ollama
  services.ollama = {
    enable = true;
  };

  # Add NixOS system packages (complementary to Home Manager packages)
  environment.systemPackages = with pkgs; [
    dconf2nix
    gcc
    ghostty
    gnome-tweaks
    gnomeExtensions.awesome-tiles
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.extension-list
    wl-clipboard
    xclip
  ];
}
