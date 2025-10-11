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

  # Syncthing is now managed by Home Manager for consistency across platforms
  # This ensures the same configuration works on both Darwin and Linux

  # --- Additional System Packages ---
  environment.systemPackages = with pkgs; [
    firefox
    # Essential desktop utilities for i3
    i3status           # Status bar for i3
    dmenu             # Application launcher
    alacritty         # Terminal emulator
    pcmanfm           # File manager
    feh               # Image viewer and wallpaper setter
    # Network and system utilities
    networkmanagerapplet  # Network manager GUI
    pavucontrol       # PulseAudio volume control
    flameshot         # Screenshot tool
    xfce.mousepad     # Simple text editor
  ];

  # --- Firefox system-wide ---
  programs.firefox.enable = true;

  # --- State Version (preserve from migration) ---
  # This value determines the NixOS release from which the default
  # settings for stateful data were taken. Important for stability.
  system.stateVersion = "24.05"; # Keep consistent with original
}