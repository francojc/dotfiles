# Determinate Nix integration for nix-darwin.
#
# Determinate Nix is the Nix installer/daemon on these Macs. The virby builder
# that used to live next to this (modules/darwin/virby.nix) was disabled and has
# been removed together with its cachix substituter.
#
# Imported by profiles/darwin/minimal.nix, so every Mac gets it.
{determinate, ...}: {
  imports = [determinate.darwinModules.default];

  # The Determinate installer writes a stub /etc/nix/nix.custom.conf (two
  # comment lines). nix-darwin refuses to overwrite unknown /etc files, so
  # whitelist that stub's hash; first activation then replaces it cleanly.
  environment.etc."nix/nix.custom.conf".knownSha256Hashes = [
    "3bd68ef979a42070a44f8d82c205cfd8e8cca425d91253ec2c10a88179bb34aa" # installer stub
  ];
}
