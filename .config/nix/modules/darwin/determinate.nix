# Determinate Nix integration for nix-darwin.
#
# Determinate Nix is the Nix installer/daemon on these Macs. The virby builder
# that used to live next to this (modules/darwin/virby.nix) was disabled and has
# been removed together with its cachix substituter.
{determinate, ...}: {
  imports = [determinate.darwinModules.default];
}
