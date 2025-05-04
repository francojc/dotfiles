{
  username,
  hostname,
  pkgs,
  ...
}: {
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [username];

  system.stateVersion = "24.05"; # Keep consistent
}
