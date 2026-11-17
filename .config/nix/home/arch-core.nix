# Arch / Omarchy user packages.
#
# The package list lives in lib/packages/arch.nix, shared with the
# packages.aarch64-linux.<host>-global-tools outputs in flake.nix. The list is
# curated so Nix does not shadow Omarchy's pacman packages (see that file).
{pkgs, ...}: {
  home.packages = import ../lib/packages/arch.nix pkgs;

  # GnuPG -- managed via home-manager for agent lifecycle control
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 34560000;
    maxCacheTtl = 34560000;
    pinentry.package = pkgs.pinentry-tty;
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };
}
