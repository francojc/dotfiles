{
  pkgs,
  hostname,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # --- Core NixOS Settings ---
  networking.hostName = hostname;
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs.zsh.enable = true; # Enable Zsh

  # Define the primary user for NixOS
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["wheel" "networkmanager" "audio"]; # Add audio group for RDP
    shell = pkgs.zsh;
    home = "/home/${username}";
  };

  # --- X11 + i3 Desktop Environment ---
  services.xserver = {
    enable = true;

    # i3 window manager
    windowManager.i3.enable = true;

    # LightDM display manager
    displayManager.lightdm.enable = true;

    # Video drivers for Mac Mini 2011
    videoDrivers = ["intel" "modesetting"];

    # Enable touchpad support (if needed)
    # libinput.enable = true;
  };

  # --- Remote Desktop (XRDP) ---
  services.xrdp = {
    enable = true;
    defaultWindowManager = "${pkgs.i3}/bin/i3";
    openFirewall = true; # Opens port 3389
  };

  # --- Audio Support ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Networking ---
  networking.networkmanager.enable = true;

  # --- SSH Server ---
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  # --- Bootloader (systemd-boot with EFI) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- System Packages ---
  environment.systemPackages = with pkgs; [
    i3
    firefox
    ghostty
    # Add other packages as needed
  ];

  # --- Firefox system-wide ---
  programs.firefox.enable = true;

  # --- State Version (preserve from migration) ---
  # This value determines the NixOS release from which the default
  # settings for stateful data were taken. Important for stability.
  system.stateVersion = "24.05"; # Keep consistent with original
}