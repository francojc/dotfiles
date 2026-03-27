# Host-specific configuration for Mini-Rover (Mac Mini 2011)
{
  # System configuration
  system = "x86_64-linux";

  # User configuration
  username = "jeridf";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "nightfox"; # options: arthur, ayu, blackmetal, catppuccin, gruvbox, kanso, nightfox, onedark, tokyonight, vague, vscode

  # Host-specific modules
  hostModules = [
    ../../profiles/nixos/configuration.nix
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  # Home Manager host-specific modules (if any)
  homeModules = [];
}
