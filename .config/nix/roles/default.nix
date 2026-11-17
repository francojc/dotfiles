# Named Home Manager role lists. Hosts compose these in `homeModules`.
#
# Plain imports only: no options. Order matters for `home.packages` and
# string merges, so it mirrors the old if/else in home/default.nix.
let
  core = ./core;
  heavy = ./heavy;
in rec {
  # Everything the old non-Arch branch of home/default.nix imported
  # (plus the shared sync/docs/mail modules that every host used to get).
  # Now used only by Mini-Rover (untouched by the Mac demotion).
  legacyFull = [
    (heavy + "/sync.nix")
    (heavy + "/docs.nix")
  #  (heavy + "/mail.nix")
    (core + "/packages.nix")
    (core + "/gpg.nix")
    (core + "/git.nix")
    (core + "/terminal.nix")
    (core + "/shell.nix")
    (core + "/tmux.nix")
    (core + "/editor.nix")
  ];

  # Minimal macOS hosts (Mac-Minicore, Macbook-Airborne): shell, git, editor,
  # tmux, terminal, gpg and a short package list. No mail, docs, sync or LSPs.
  mac = [
    (core + "/packages-mac.nix")
    (core + "/gpg.nix")
    (core + "/git.nix")
    (core + "/terminal.nix")
    (core + "/shell.nix")
    (core + "/tmux.nix")
    (core + "/editor.nix")
  ];

  # Arch / Omarchy user environment. Nix manages only what Omarchy does not
  # ship; git and kitty are deliberately absent (see docs/arch-omarchy.md).
  arch = [
    (heavy + "/sync.nix")
    (heavy + "/docs.nix")
  #  (heavy + "/mail.nix")
    (heavy + "/dev-tools.nix")
    (heavy + "/media.nix")
    (core + "/packages-arch.nix")
    (core + "/gpg.nix")
    (core + "/shell-arch.nix")
    (core + "/tmux-arch.nix")
    (core + "/terminal-arch.nix")
    (core + "/editor.nix")
  ];
}
