# Host-specific configuration for Macbook-Airborne
{
  # System configuration
  system = "aarch64-darwin";
  
  # User configuration
  username = "francojc";
  useremail = "francojc@wfu.edu";
  
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