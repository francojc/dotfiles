{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    material-design-icons
    font-awesome
    nerd-fonts.symbols-only
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];
}
