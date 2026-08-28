# aarch64 NixOS guest for a Parallels Desktop lab on Apple Silicon.
{
  system = "aarch64-linux";
  username = "jeridf";
  useremail = "francojc@wfu.edu";
  theme = "ayu";

  hostModules = [
    ../../profiles/nixos/configuration.nix
    ../../profiles/nixos/quattro.nix
    ./configuration.nix
  ];

  homeModules = [
    ../../home/quattro.nix
  ];
}
