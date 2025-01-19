{ pkgs, ... }:
let
  inherit (pkgs) lib;
in
{
  system = {
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
    imports = [
      ./system/defaults.nix
      ./system/trackpad.nix
      ./system/finder.nix
      ./system/keyboard.nix
      ./system/custom-user-preferences.nix
      ./system/loginwindow.nix
    ];
    startup.chime = false; # no startup sound ;)
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  programs.zsh.enable = true; # enable zsh

  environment = {
    shells = [ pkgs.zsh ];
    variables.HOMBREW_NO_ANALYTICS = "1";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Fonts
  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome
      nerd-fonts.symbols-only
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
    ];
  };
}
