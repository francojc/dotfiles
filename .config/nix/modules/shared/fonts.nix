{pkgs, ...}: {
  fonts.packages = with pkgs; [
    aporetic
    font-awesome
    maple-mono.truetype
    material-design-icons
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    nerd-fonts.symbols-only
  ];
}
