{
  isDarwin,
  isLinux,
  ...
}: {
  # Enable Syncthing service for Home Manager
  services.syncthing = {
    enable = true;
    # Home Manager handles the service configuration automatically
    # On macOS, this creates a LaunchAgent
    # On Linux, this creates a user systemd service
  };
}