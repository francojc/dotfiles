# Host-specific configuration for Nix-Rover
{
  # System configuration
  system = "aarch64-linux";
  
  # User configuration
  username = "jeridf";
  useremail = "francojc@wfu.edu";
  
  # Theme selection for this host
  theme = "arthur";  # options: gruvbox, nightfox, arthur, onedark
  
  # Host-specific modules
  hostModules = [
    ../nixos/configuration.nix
  ];
  
  # Home Manager host-specific modules (if any)
  homeModules = [
    ../nixos/dconf.nix
    # Add other host-specific home manager modules here if needed
  ];
}