{ pkgs, ... }:
{
  system.defaults = {
    ActivityMonitor.IconType = 5;

    menuExtraClock = {
      Show24Hour = true;
      ShowAMPM = false;
      ShowDate = 2;
    };

    dock = {
      autohide = true;
      expose-group-apps = true;
      orientation = "bottom";
      show-recents = false;
      wvous-tl-corner = 5;
      wvous-tr-corner = 4;
      wvous-bl-corner = 2;
      wvous-br-corner = 3;
    };
  };
}
