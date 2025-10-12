{
  isDarwin,
  isLinux,
  username,
  ...
}: {
  # Enable Syncthing service for Home Manager
  services.syncthing = {
    enable = true;
  };
}

