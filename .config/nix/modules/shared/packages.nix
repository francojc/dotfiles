{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    age # Encryption
    alejandra # Formatter
    btop # Interactive process viewer
    carapace
    codespell
    curl
    direnv
    git
    htop # Included in NixOS template
    just # Task runner
    lynx
    nixd # Language server
    nodejs_22 # Node.js for bleeding-edge npm packages
    nurl # Nix URL fetcher helper
    stylua # Lua formatter
    vim # Basic editor
    viu
    w3m
    wget # Included in NixOS template
  ];
}
