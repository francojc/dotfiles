{ pkgs, ... }:
{
  system.defaults.finder = {
    _FXShowPosixPathInTitle = false;
    AppleShowAllExtensions = true;
    FXEnableExtensionChangeWarning = false;
    FXPreferredViewStyle = "Nlsv";
    QuitMenuItem = true;
    ShowPathbar = true;
    ShowStatusBar = true;
  };
}
