{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Common CLI tools found in both original lists
    alejandra # Formatter
    age # Encryption
    curl
    direnv
    git
    glow # Markdown renderer
    htop # Included in NixOS template
    just # Task runner
    lla # Alias manager (assuming available on both)
    nixd # Language server
    nurl # Nix URL fetcher helper
    stylua # Lua formatter
    vim # Basic editor
    wget # Included in NixOS template
  ];
}
