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
    # Essential desktop utilities for i3
    # Network and system utilities
    alacritty # Terminal emulator
    dmenu # Application launcher
    feh # Image viewer and wallpaper setter
    firefox
    flameshot # Screenshot tool
    i3status # Status bar for i3
    neovim # Text editor
    kitty # Terminal emulator
    networkmanagerapplet # Network manager GUI
    pavucontrol # PulseAudio volume control
    pcmanfm # File manager
    xfce.mousepad # Simple text editor
  ];

  # --- Firefox system-wide ---
  programs.firefox.enable = true;

  # --- State Version (preserve from migration) ---
  # This value determines the NixOS release from which the default
  # settings for stateful data were taken. Important for stability.
  system.stateVersion = "24.05"; # Keep consistent with original
}
