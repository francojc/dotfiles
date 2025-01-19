{ pkgs, ... }:
{
  system = {
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
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
        wvous-bl-corner = 2;
        wvous-br-corner = 3;
        wvous-tl-corner = 5;
        wvous-tr-corner = 4;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      NSGlobalDomain = {
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleSpacesSwitchOnActivate = false;
        InitialKeyRepeat = 10;
        KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSTableViewDefaultSizeMode = 3;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.swipescrolldirection" = true;
      };

      loginwindow = {
        GuestEnabled = true;
      };

      CustomUserPreferences = {
        ".GlobalPreferences" = {
          AppleSpacesSwitchOnActivate = true;
        };
        NSGlobalDomain = {
          WebKitDeveloperExtras = true;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.finder" = {
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          ShowExternalHardDrivesOnDesktop = false;
          ShowHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
        };
        "com.apple.ImageCapture" = {
          disableHotPlug = true;
        };
        "com.apple.LaunchServices" = {
          LSQuarantine = true;
        };
        "com.apple.screensaver" = {
          askForPassword = 0;
          askForPasswordDelay = 0;
        };
         "com.apple.screencapture" = {
          disable-shadow = true;
          location = "~/Downloads";
          type = "png";
        };
        "com.apple.spaces" = {
          "spans-displays" = 0;
        };
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0;
          HideDesktop = 1;
          StageManagerHideWidgets = 0;
          StandardHideDesktopIcons = 0;
          StandardHideWidgets = 1;
        };
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
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
