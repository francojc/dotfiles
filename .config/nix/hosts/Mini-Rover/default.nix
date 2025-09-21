# Host-specific configuration for Mini-Rover (Mac Mini 2011)
{
  # System configuration
  system = "x86_64-linux";

  # User configuration
  username = "jeridf";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "nightfox"; # options: arthur, autumn, blackmetal, gruvbox, nightfox, arthur, onedark

  # Host-specific modules
  hostModules = [
    ../../profiles/nixos/configuration.nix
    ../../profiles/nixos/i3.nix
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  # Home Manager host-specific modules (if any)
  homeModules = [
    # X11/i3 compatible modules - no Wayland/Sway modules
    # i3 configuration is now included in main home config for Linux hosts
  ];
}
