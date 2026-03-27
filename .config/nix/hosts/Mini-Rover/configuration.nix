{
  pkgs,
  username,
  ...
}: {
  # Host-specific overrides and additional configuration for Mini-Rover

  users.users.${username}.extraGroups = ["wheel" "networkmanager" "audio"];

  # --- Bootloader (systemd-boot with EFI) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- SSH Server ---
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  # --- Desktop Environment (GNOME + GDM) ---
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # --- Keyboard ---
  services.xserver.xkb = {
    layout = "us";
    options = "ctrl:nocaps";
  };

  # --- Remote Desktop (xrdp) ---
  services.xrdp = {
    enable = true;
    defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
    openFirewall = true;
  };

  # --- Additional System Packages ---
  environment.systemPackages = with pkgs; [
    alacritty # Terminal emulator
    firefox
    flameshot # Screenshot tool
    kitty # Terminal emulator
    pavucontrol # PulseAudio volume control
    gnome-extensions-cli # Manage GNOME extensions from terminal
    mousepad # Simple text editor
  ];

  # --- Firefox system-wide ---
  programs.firefox.enable = true;

  # --- State Version (preserve from migration) ---
  # This value determines the NixOS release from which the default
  # settings for stateful data were taken. Important for stability.
  system.stateVersion = "24.05"; # Keep consistent with original
}
