{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    btop # Interactive process viewer
    curl # tool to transfer data with URL syntax
    git # version control
    htop # Included in NixOS template
    just # Task runner
    lynx # Text browser
    nodejs_22 # Node.js for bleeding-edge npm packages
    tmux # Terminal multiplexer
    uv # python package manager
    vim # Basic editor
    viu # Image viewer
    w3m # Text browser
    wget # Download tool
  ];
}
