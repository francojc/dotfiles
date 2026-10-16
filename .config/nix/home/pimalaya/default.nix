# Pimalaya stack (Mode B) -- direct IMAP/SMTP/CardDAV/CalDAV.
# Parallel to aerc/khal/vdirsyncer.
#
# Package split:
# - himalaya (CLI): nixpkgs (2.2.1)
# - himalaya-tui, cardamum, calendula: pre-resolved in flake.nix and exposed
#   via `extraSpecialArgs.pimalaya` (one attrset, keyed by tool name).
{pkgs, pimalaya, ...}:
{
  home.packages = [
    pkgs.himalaya
    pimalaya.himalaya-tui
    pimalaya.cardamum
    pimalaya.calendula
  ];

  xdg.configFile."himalaya/config.toml".source  = ./himalaya.toml;
  xdg.configFile."cardamum/config.toml".source  = ./cardamum.toml;
  xdg.configFile."calendula/config.toml".source = ./calendula.toml;
}
