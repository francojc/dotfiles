# --- Replace nixos-vm with your actual hostname ---
{
  config,
  pkgs,
  lib,
  inputs,
  hostname,
  username,
  ...
}:
# Receive specialArgs
{
  imports = [
    ./hardware-configuration.nix # Generated on the target machine
    # Import shared system modules (relative path from flake root)
    ../../modules/shared/nix-core.nix
    # Import NixOS-specific modules if you create any
    # ../../modules/nixos/some-nixos-module.nix
  ];

  # --- Core NixOS Settings ---
  networking.hostName = hostname; # Use hostname from specialArgs
  time.timeZone = "America/New_York"; # Set your timezone
  i18n.defaultLocale = "en_US.UTF-8";
  # console.keyMap = "us"; # If needed

  # Define the primary user for NixOS
  users.users.${username} = {
    isNormalUser = true;
    description = username; # Use username from specialArgs
    extraGroups = ["wheel" "networkmanager"]; # Common groups, add others if needed
    # Shell is managed by Home Manager
    home = "/home/${username}"; # Standard Linux home
  };

  # Add NixOS system packages (complementary to Home Manager packages)
  environment.systemPackages = with pkgs; [
    vim # Basic editor often useful
    git
    wget
    curl
    htop
    # Add any other system-level tools here
  ];

  # Allow flakes & nix command for the root user too
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # --- NixOS Specific services / settings ---
  # Example: Enable SSH server
  # services.openssh = {
  #   enable = true;
  #   settings.PasswordAuthentication = false; # Recommend key-based auth
  #   settings.KbdInteractiveAuthentication = false;
  # };

  # Example: Bootloader (adjust for your system, e.g., UEFI or BIOS)
  boot.loader.systemd-boot.enable = true; # For UEFI systems
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.enable = true; # For BIOS or if you prefer GRUB
  # boot.loader.grub.device = "/dev/sdX"; # Set your boot disk

  # Example: Networking (enable NetworkManager is common for desktops/laptops)
  networking.networkmanager.enable = true;

  # --- !! Home Manager is configured via the flake !! ---

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s important to update this value
  # when upgrading NixOS -> see nixos-rebuild switch documentation.
  system.stateVersion = "23.11"; # Or "24.05", etc. Set to the version you installed with.
}
