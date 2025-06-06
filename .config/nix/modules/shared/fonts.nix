{pkgs, ...}: {
  fonts.packages = with pkgs; [
    material-design-icons
    font-awesome
    aporetic
    nerd-fonts.symbols-only
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];
}
