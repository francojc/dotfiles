# Host-specific configuration for Mac-Minicore
{
  # System configuration
  system = "aarch64-darwin";
  
  # User configuration
  username = "jeridf";
  useremail = "francojc@wfu.edu";
  
  # Theme selection for this host
  theme = "nightfox";  # options: gruvbox, nightfox, arthur, onedark
  
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