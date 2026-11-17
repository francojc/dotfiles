# Media and mail-client packages role (aerc, khal, vdirsyncer, sioyek, ...).
{pkgs, ...}: {
  home.packages = import ../../lib/packages/media.nix pkgs;
}
