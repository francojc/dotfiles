# Arch / Omarchy core user packages: CLI utilities plus the Arch-only extras.
#
# The full list (core + heavy roles) is also available as
# lib/packages/arch.nix, used by the packages.aarch64-linux.<host>-global-tools
# flake outputs. The list is curated so Nix does not shadow Omarchy's pacman
# packages (see lib/packages/arch.nix).
{pkgs, ...}: {
  home.packages =
    import ../../lib/packages/cli.nix pkgs
    ++ import ../../lib/packages/arch-extra.nix pkgs;
}
