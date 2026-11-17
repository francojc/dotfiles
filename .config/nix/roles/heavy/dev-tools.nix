# Developer tooling role: language servers, formatters and dev utilities.
{pkgs, ...}: {
  home.packages =
    import ../../lib/packages/lsp.nix pkgs
    ++ import ../../lib/packages/dev.nix pkgs;
}
