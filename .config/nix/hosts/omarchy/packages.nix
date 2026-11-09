# Omarchy Nix-lite global package list (PLAN-nix-lite.md §4c).
#
# Consumed by:
#   - flake.nix: packages.aarch64-linux.omarchy-global-tools (nix profile install)
#   - home/arch-core.nix: home.packages (Home Manager phase, not activated yet)
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
  lsp = import ../../lib/packages/lsp.nix pkgs;
  cli = import ../../lib/packages/cli.nix pkgs;
  dev = import ../../lib/packages/dev.nix pkgs;
  media = import ../../lib/packages/media.nix pkgs;

  # Omarchy-only additions
  omarchyOnly = with pkgs; [
    copilot-language-server # Copilot LSP for Next Edit Suggestions
    nix-doc # Nix documentation server
    chafa # Terminal image viewer (snacks.nvim image support)
    websocat # WebSocket client
    glow # Markdown renderer
    marp-cli # Markdown presentation tool
    nix-prefetch-git
    just # run project commands
    tectonic # LaTeX rendering for math expressions
    pass # Password manager (not shipped by Omarchy; was pacman explicit)
    tree # Directory listing tool (dependency of pass; moves with it)
    (pkgs.glances.overridePythonAttrs (_old: {doCheck = false;})) # TODO: drop once nixpkgs glances tests stabilise
  ];
in
  lsp ++ cli ++ dev ++ media ++ omarchyOnly
