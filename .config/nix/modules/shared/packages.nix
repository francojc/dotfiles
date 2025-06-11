{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    age # Encryption
    alejandra # Formatter
    brave
    browsh
    carapace
    codespell
    curl
    direnv
    git
    glow # Markdown renderer
    htop # Included in NixOS template
    just # Task runner
    lla # Alias manager (assuming available on both)
    lynx
    nixd # Language server
    nurl # Nix URL fetcher helper
    ollama # AI assistant
    oterm
    stylua # Lua formatter
    vim # Basic editor
    viu
    w3m
    wget # Included in NixOS template
  ];
}
