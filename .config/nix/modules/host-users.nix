{ username, hostname, pkgs, ... }: {
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  # Add nushell to /etc/shells
  environment.shells = [ pkgs.nushell ];

  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [ username ];
}
