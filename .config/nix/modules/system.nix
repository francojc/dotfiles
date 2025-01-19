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
      ./dock.nix
      ./trackpad.nix
      ./finder.nix
      ./keyboard.nix
      ./user-preferences.nix
      ./loginwindow.nix
    ];
    defaults.menuExtraClock = {
      Show24Hour = true;
      ShowAMPM = false;
      ShowDate = 2;
    };
    startup.chime = false;
  };

  security.pam.enableSudoTouchIdAuth = true;

  programs.zsh.enable = true;

  environment = {
    shells = [ pkgs.zsh ];
    variables.HOMBREW_NO_ANALYTICS = "1";
  };

  time.timeZone = "America/New_York";

  fonts = {
    packages = with pkgs; [
      material-design-icons
      font-awesome
      nerd-fonts.symbols-only
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
    ];
  };
}
