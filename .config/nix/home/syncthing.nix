{...}: {
  # Enable Syncthing service for Home Manager
  services.syncthing = {
    enable = true;
    settings = {
      folders = {
        "pi-memory" = {
          path = "~/.local/share/pi-memory";
          label = "Pi Memory";
          rescanIntervalS = 3600;
          fsWatcherEnabled = true;
          fsWatcherDelayS = 10;
        };
      };
    };
  };
}
