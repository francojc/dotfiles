# Arch / Omarchy inside the try-omarchy VM (Omarchy-Mini).
#
# try-omarchy is a stock Omarchy guest plus one package (`try-omarchy`) that
# owns the Mac integrations: software-GL wrappers for kitty/ghostty, the 9p
# shared-folder mount, clipboard/audio/camera bridges. This profile therefore
# stays small; it only records what Home Manager needs to know about the guest.
#
# Not here, on purpose:
#   - kitty software-GL wrapper: try-omarchy installs /usr/lib/try-omarchy/bin/kitty
#     itself, and the Arch hosts do not import home/kitty.nix.
#   - sioyek portal override: already applied on every Linux host in
#     lib/packages/media.nix.
#   - Tailscale, the guest's Nix daemon: installed on the guest, not by HM.
{
  config,
  lib,
  ...
}: {
  home.sessionVariables = {
    # Mac folder shared by try-omarchy: /Users/jeridf/Projects on the host,
    # mounted at /mnt/mac (9p, cache=readahead) and linked to ~/Projects.
    # Git works there; keep databases, SQLite WAL, mmap-heavy tools and build
    # caches on the guest disk (see docs/shared-folder-safety.md upstream).
    PROJECTS_DIR = "${config.home.homeDirectory}/Projects";
  };

  # Heavy cache directories belong on the guest disk, not the shared folder.
  home.sessionVariables.XDG_CACHE_HOME = lib.mkDefault "${config.home.homeDirectory}/.cache";
}
