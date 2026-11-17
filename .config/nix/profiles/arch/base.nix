# Arch / Omarchy integration for standalone Home Manager.
#
# Omarchy is Arch Linux + Hyprland. Nix does not manage the OS here, so this
# module contains only what a user-level Home Manager configuration needs to
# coexist with Omarchy:
#
#   * `targets.genericLinux` -- links the Home Manager profile into the system
#     paths an Arch login session reads (PATH, XDG_DATA_DIRS, ...). Without it,
#     Nix-installed GUI applications and desktop entries are not discovered.
#   * the flake overlay -- so custom packages such as `pdc-mdpdf` resolve.
#   * `allowUnfree` -- mirrors modules/shared/nix-core.nix, which is not loaded
#     for standalone Home Manager.
#   * Omarchy's environment bootstrap -- exports OMARCHY_PATH and appends the
#     mise/local tool paths. The snippet is POSIX and safe to source from zsh;
#     the rest of Omarchy's bash rc chain (aliases, functions, inputrc) is
#     bash-specific and is intentionally not sourced here.
{
  self,
  lib,
  ...
}: {
  targets.genericLinux.enable = true;

  nixpkgs.overlays = [self.overlays.default];
  nixpkgs.config.allowUnfree = true;

  programs.zsh.profileExtra = lib.mkAfter ''
    # --- Omarchy environment (mirrors /etc/profile.d/omarchy.sh) ---
    if [ -r /usr/share/omarchy/default/bash/env-bootstrap ]; then
      . /usr/share/omarchy/default/bash/env-bootstrap
    fi
  '';
}
