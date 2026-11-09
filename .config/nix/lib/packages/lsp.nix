# Language servers and formatters shared by every host (Mac and Omarchy).
# Each file in lib/packages is `pkgs: [ ... ]`, so both `buildEnv` (flake
# packages output) and Home Manager (`home.packages`) can consume it.
pkgs:
with pkgs; [
  # Language servers (LSPs)
  bash-language-server
  golangci-lint-langserver
  gopls
  lua-language-server
  marksman
  nixd
  pyright
  tinymist
  typescript-language-server
  vscode-json-languageserver
  yaml-language-server

  # Formatters & linters
  air-formatter # R LSP/formatter
  alejandra # Nix formatter
  mdformat # Markdown formatter
  ruff # Python linter/formatter
  shfmt # Shell formatter
  stylua # Lua formatter
]
