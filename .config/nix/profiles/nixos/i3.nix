{pkgs, ...}: {
  # --- X11 + i3 Desktop Environment ---
  services.xserver = {
    enable = true;

    # i3 window manager
    windowManager.i3.enable = true;

    # LightDM display manager
    displayManager.lightdm.enable = true;

    # Video drivers for older hardware (can be overridden in host-specific configs)
    videoDrivers = ["intel" "modesetting"];

    # Avoid tearing
    deviceSection = ''
      Option "TearFree" "true"
    '';

    # Enable touchpad support (if needed)
    # libinput.enable = true;
  };

  # --- XDG Portal for X11 (required for Flatpak integration) ---
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # --- Remote Desktop (XRDP) ---
  services.xrdp = {
    enable = true;
    defaultWindowManager = "${pkgs.i3}/bin/i3";
    openFirewall = true; # Opens port 3389
  };

  # --- System Packages for i3 ---
  environment.systemPackages = with pkgs; [
    i3
  ];
}

