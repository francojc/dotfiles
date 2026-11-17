# Arch / Omarchy package list, shared by every Arch host (Omarchy-Air,
# Omarchy-Mini, ...). Lives next to the other shared groups in lib/packages.
#
# Consumed by:
#   - flake.nix: packages.aarch64-linux.<host>-global-tools, one per Arch host
#     (nix profile install)
#   - home/arch-core.nix: home.packages
#
# Not here, on purpose:
#   - compilers and build tools (gcc, make, rustc, cargo, go, gnumake): pacman
#   - runtimes (node, python, uv, typescript): mise
#   - GUI apps (tenacity, wezterm): pacman/AUR
#   - lazygit (Omarchy base), gh (Omarchy mise default): not Nix
#   - typst and quarto: per-repo devShells (nix develop)
#   - anything in /usr/share/omarchy/install/omarchy-base.packages
#   - anything Omarchy declares in /etc/mise/conf.d/omarchy-tools.toml or offers
#     through omarchy-install-* (e.g. go, rust via dev-env)
pkgs: let
  lsp = import ./lsp.nix pkgs;
  cli = import ./cli.nix pkgs;
  dev = import ./dev.nix pkgs;
  media = import ./media.nix pkgs;
  extra = import ./arch-extra.nix pkgs;
in
  lsp ++ cli ++ dev ++ media ++ extra
