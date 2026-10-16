# Pimalaya stack (Mode B) -- direct IMAP/SMTP/CardDAV/CalDAV.
# Parallel to aerc/khal/vdirsyncer.
#
# Package split:
# - himalaya (CLI): nixpkgs (2.2.1) -- already bundles zsh completion
# - himalaya-tui, cardamum, calendula: pulled from flake inputs declared in
#   the top-level flake.nix and surfaced via `extraSpecialArgs.pimalaya`.
#   Each is wrapped here with `overrideAttrs` to add a postInstall step that
#   copies its zsh completion into `share/zsh/site-functions/`. Home Manager's
#   `programs.zsh.enable = true` automatically picks them up via fpath.
{pkgs, pimalaya, ...}:
let
  # Add a zsh completion file alongside the packaged binary so HM/zsh
  # autoload picks it up the same way it does for nixpkgs himalaya.
  pkgsWithCompletion = pkg: tool: pkg.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      mkdir -p $out/share/zsh/site-functions
      $out/bin/${tool} completion zsh > $out/share/zsh/site-functions/_${tool}
    '';
  });

  cardamum      = pkgsWithCompletion pimalaya.cardamum      "cardamum";
  calendula     = pkgsWithCompletion pimalaya.calendula     "calendula";
  himalaya-tui  = pkgsWithCompletion pimalaya.himalaya-tui  "himalaya-tui";
in {
  home.packages = [
    pkgs.himalaya
    himalaya-tui
    cardamum
    calendula
  ];

  xdg.configFile."himalaya/config.toml".source  = ./himalaya.toml;
  xdg.configFile."cardamum/config.toml".source  = ./cardamum.toml;
  xdg.configFile."calendula/config.toml".source = ./calendula.toml;
}
