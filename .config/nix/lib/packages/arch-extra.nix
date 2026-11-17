# Packages only the Arch/Omarchy hosts get (not shared with the Macs).
# Part of lib/packages/arch.nix; split out so roles/core can import it
# without the lsp/dev/media groups that roles/heavy owns.
pkgs:
with pkgs; [
    copilot-language-server # Copilot LSP for Next Edit Suggestions
    nix-doc # Nix documentation server
    chafa # Terminal image viewer (snacks.nvim image support)
    websocat # WebSocket client
    glow # Markdown renderer
    pandoc # Markdown converter (aerc text/html alternative via aerc-use-pandoc / emailmd-convert)
    marp-cli # Markdown presentation tool
    nix-prefetch-git
    just # run project commands
    bob-nvim # Neovim version manager: pre-releases (repo needs Neovim 0.13+)

    # tmux plugins loaded from ~/.nix-profile/share/tmux-plugins (.config/tmux/overrides.conf)
    tmuxPlugins.fzf-tmux-url
    tmuxPlugins.vim-tmux-navigator
    tmuxPlugins.yank
    tectonic # LaTeX rendering for math expressions
    pass # Password manager (not shipped by Omarchy; was pacman explicit)
    tree # Directory listing tool (dependency of pass; moves with it)
    (pkgs.glances.overridePythonAttrs (_old: {doCheck = false;})) # TODO: drop once nixpkgs glances tests stabilise
]
