{
  isDarwin,
  isLinux,
  username,
  ...
}: {
  # Enable Syncthing service for Home Manager
  # This configuration works consistently across Darwin and Linux
  services.syncthing = {
    enable = true;
  };

  # Platform-specific package additions for better desktop integration
  home.packages =
    if isLinux
    then [ /* Can add syncthingtray or other Linux GUI tools here */ ]
    else [ /* Can add macOS-specific tools here if needed */ ];
}