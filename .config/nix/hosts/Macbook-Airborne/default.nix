# Host-specific configuration for Macbook-Airborne
{
  # System configuration
  system = "aarch64-darwin";

  # User configuration
  username = "francojc";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "vague"; # options: arthur, autumn, gruvbox, nightfox, onedark, vague

  # Host-specific modules
  hostModules = [
    ../darwin/configuration.nix
  ];

  # Home Manager host-specific modules (if any)
  homeModules = [
    # Add host-specific home manager modules here if needed
    # ./home.nix
  ];
}
