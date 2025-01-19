{ pkgs, ... }:
{
  system.defaults.NSGlobalDomain = {
    "com.apple.swipescrolldirection" = true;
    "com.apple.sound.beep.feedback" = 0;
    AppleKeyboardUIMode = 3;
    AppleInterfaceStyleSwitchesAutomatically = true;
    ApplePressAndHoldEnabled = false;
    NSTableViewDefaultSizeMode = 3;
    AppleShowAllExtensions = true;
    AppleSpacesSwitchOnActivate = false;

    InitialKeyRepeat = 10;
    KeyRepeat = 1;

    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
  };

  system.defaults.CustomUserPreferences = {
    ".GlobalPreferences" = {
      AppleSpacesSwitchOnActivate = true;
    };
    NSGlobalDomain = {
      WebKitDeveloperExtras = true;
    };
    "com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
    };
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.spaces" = {
      "spans-displays" = 0;
    };
    "com.apple.LaunchServices" = {
      LSQuarantine = true;
    };
    "com.apple.WindowManager" = {
      EnableStandardClickToShowDesktop = 0;
      StandardHideDesktopIcons = 0;
      HideDesktop = 1;
      StageManagerHideWidgets = 0;
      StandardHideWidgets = 1;
    };
    "com.apple.screensaver" = {
      askForPassword = 0;
      askForPasswordDelay = 0;
    };
    "com.apple.screencapture" = {
      location = "~/Downloads";
      type = "png";
      disable-shadow = true;
    };
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };
    "com.apple.ImageCapture".disableHotPlug = true;
  };
}
