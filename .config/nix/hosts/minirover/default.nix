# Host-specific configuration for minirover (Mac Mini 2011)
{
  # System configuration
  system = "x86_64-linux";

  # User configuration
  username = "jeridf";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "gruvbox"; # options: gruvbox, nightfox, arthur, onedark

  # Host-specific modules
  hostModules = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  # Home Manager host-specific modules (if any)
  homeModules = [
    # X11/i3 compatible modules - no Wayland/Sway modules
    # Add i3-specific home manager modules here if needed
  ];
}

