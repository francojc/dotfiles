{
  pkgs,
  hostname,
  username,
  ...
}: {

  # --- Core NixOS Settings ---
  networking.hostName = hostname;
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

  programs.zsh.enable = true; # Enable Zsh

  # Define the primary user for NixOS
  users.users.${username} = {
    isNormalUser = true;
    description = username; # Use username from specialArgs
    extraGroups = ["wheel" "networkmanager"]; # Common groups, add others if needed
    shell = pkgs.zsh; # Use Zsh as the default shell
    home = "/home/${username}"; # Standard Linux home
  };

  # --- System Packages (Common) ---
  environment.systemPackages = with pkgs; [
    ghostty
  ];

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

  # --- Other System Services (shared across NixOS hosts) ---
  networking.networkmanager.enable = true;

  # --- !! Home Manager is configured via the flake !! ---

  # Note: stateVersion should be set in host-specific configuration
  # Note: bootloader and SSH settings should be host-specific
}
