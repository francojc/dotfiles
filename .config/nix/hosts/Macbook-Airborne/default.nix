# Host-specific configuration for Macbook-Airborne
{
  # System configuration
  system = "aarch64-darwin";

  # User configuration
  username = "francojc";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "vscode"; # options: arthur, autumn, ayu, blackmetal, gruvbox, nightfox, onedark, vague, vscode, catppuccin, tokyonight

  # Host-specific modules
  hostModules = [
    ../../profiles/darwin/configuration.nix
    ../../modules/darwin/reddix.nix
  ];

  # Home Manager host-specific modules (if any)
  homeModules = [
    # Add host-specific home manager modules here if needed
    # ./home.nix
  ];
}
