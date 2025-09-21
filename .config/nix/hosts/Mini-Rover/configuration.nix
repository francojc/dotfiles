{
  pkgs,
  username,
  ...
}: {
  # Host-specific overrides and additional configuration for Mini-Rover

  # Add audio group for RDP functionality
  users.users.${username}.extraGroups = ["wheel" "networkmanager" "audio"];

  # --- Bootloader (systemd-boot with EFI) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- SSH Server ---
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  # --- Additional System Packages ---
  environment.systemPackages = with pkgs; [
    firefox
    # Add other host-specific packages as needed
  ];

  # --- Firefox system-wide ---
  programs.firefox.enable = true;

  # --- State Version (preserve from migration) ---
  # This value determines the NixOS release from which the default
  # settings for stateful data were taken. Important for stability.
  system.stateVersion = "24.05"; # Keep consistent with original
}