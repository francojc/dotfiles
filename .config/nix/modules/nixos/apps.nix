{pkgs, ...}: {
  # Add NixOS system packages (complementary to Home Manager packages)
  environment.systemPackages = with pkgs; [
    # Keep only NixOS-specific system packages here, if any.
    # Example: gnome packages if not pulled in by services.xserver.desktopManager.gnome.enable
    gnome.gnome-tweaks # Example of a potentially NixOS-specific addition
    # Add any other system-level tools here
  ];
}
