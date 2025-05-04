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
    ./hardware-configuration.nix
    ../../modules/shared/nix-core.nix
  ];

  # --- Core NixOS Settings ---
  # networking.hostName is set in shared/nix-core.nix via host-users.nix import? No, host-users is Darwin only. Keep it here for NixOS.
  networking.hostName = hostname;
  # time.timeZone removed (handled by shared/time.nix)
  i18n.defaultLocale = "en_US.UTF-8"; # From original config
  i18n.extraLocaleSettings = {
    # From original config
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
    # Common packages moved to shared/packages.nix:
    # vim, git, wget, curl, just, htop, alejandra, age, direnv, glow, lla, nixd, nurl, stylua
    # Keep only NixOS-specific system packages here, if any.
    # Example: gnome packages if not pulled in by services.xserver.desktopManager.gnome.enable
    gnome.gnome-tweaks # Example of a potentially NixOS-specific addition
    # Add any other system-level tools here
  ];

  # Allow flakes & nix command for the root user too
  # nix.settings.experimental-features is handled by ../../modules/shared/nix-core.nix

  # --- Desktop Environment / GUI (from original config) ---
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    # services.xserver.libinput.enable = true; # Usually enabled by default with GNOME
  };

  # --- Auto Login (from original config) ---
  services.displayManager.autoLogin = {
    enable = true;
    user = username; # Use username from specialArgs
  };
  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # --- Sound (from original config) ---
  # services.pulseaudio.enable = false; # Default anyway if pipewire is enabled
  security.rtkit.enable = true; # Often needed for pipewire realtime priorities
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # Keep if you might run 32-bit ALSA apps
    pulse.enable = true;
    # jack.enable = true; # Enable if you need JACK support
  };

  # --- Other System Services (from original config) ---
  networking.networkmanager.enable = true;
  # services.printing.enable = true; # CUPS - Let's make this shared too potentially? Or keep host specific. Keep here for now.
  services.printing.enable = true;
  programs.firefox.enable = true; # Firefox system-wide

  # Example: Bootloader (adjust for your system, e.g., UEFI or BIOS)
  boot.loader.systemd-boot.enable = true; # For UEFI systems
  boot.loader.efi.canTouchEfiVariables = true;

  # --- !! Home Manager is configured via the flake !! ---

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s important to update this value
  # when upgrading NixOS -> see nixos-rebuild switch documentation. Make consistent with HM.
  # Original was 24.11 (likely typo), HM is 24.05.
  system.stateVersion = "24.05";

  # Optional: Enable SSH server if needed
  # services.openssh = {
  #   enable = true;
  #   settings.PasswordAuthentication = false; # Recommend key-based auth
  #   settings.KbdInteractiveAuthentication = false;
  # };
}
