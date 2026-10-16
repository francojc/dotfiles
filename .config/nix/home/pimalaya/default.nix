# Pimalaya stack (Mode B) -- direct IMAP/SMTP/CardDAV/CalDAV.
# Parallel to aerc/khal/vdirsyncer.
#
# Package split:
# - himalaya (CLI): nixpkgs (2.2.1)
# - himalaya-tui, cardamum, calendula: not in nixpkgs; built from upstream
#   GitHub flakes via `builtins.getFlake`. Tracks master each rebuild.
# - To pin reproducible refs, add these as flake inputs in the top-level
#   flake.nix instead, then reference `inputs.<name>.packages.${system}.default`.
#
# Pass creds match aerc/accounts.conf: EMAIL/GMAIL, EMAIL/MAILBOX.
{pkgs, ...}:
let
  system = pkgs.stdenv.hostPlatform.system;

  # Each of these repos ships a flake.nix + package.nix. We grab the default
  # package for `system` so eval matches the host platform.
  pimalayaTools = {
    himalaya-tui = (builtins.getFlake "github:pimalaya/himalaya-tui").packages.${system}.default;
    cardamum      = (builtins.getFlake "github:pimalaya/cardamum").packages.${system}.default;
    calendula     = (builtins.getFlake "github:pimalaya/calendula").packages.${system}.default;
  };
in {
  home.packages = [
    pkgs.himalaya          # CLI; in nixpkgs
    pimalayaTools.himalaya-tui
    pimalayaTools.cardamum
    pimalayaTools.calendula
  ];

  xdg.configFile."himalaya/config.toml".source  = ./himalaya.toml;
  xdg.configFile."cardamum/config.toml".source  = ./cardamum.toml;
  xdg.configFile."calendula/config.toml".source = ./calendula.toml;
}
