{
  pkgs,
  username,
  ...
}: {
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
        autohide-delay = 0.0;
        expose-group-apps = true;
        orientation = "bottom";
        persistent-apps = [
          "/Applications/Zen Browser.app"
          "/Users/${username}/Applications/Home Manager Apps/kitty.app"
          "/System/Applications/Utilities/Screen Sharing.app"
        ];
        persistent-others = [
          "/Users/${username}/"
          "/Users/${username}/.dotfiles"
          "/Users/${username}/Downloads/"
        ];
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
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.swipescrolldirection" = true;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleSpacesSwitchOnActivate = false;
        InitialKeyRepeat = 13;
        KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSTableViewDefaultSizeMode = 3;
      };

      loginwindow = {
        GuestEnabled = false;
      };

      CustomUserPreferences = {
        NSGlobalDomain = {
          AppleReduceDesktopTinting = true;
          NSWindowAutomaticWindowAnimationsEnabled = false;
          WebKitDeveloperExtras = true;
        };
        ".GlobalPreferences" = {
          AppleSpacesSwitchOnActivate = true;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.controlcenter" = {
          "NSStatusItem Visible Battery" = 0;
          "NSStatusItem Visible BentoBox" = 1;
          "NSStatusItem Visible FocusModes" = 1;
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
          ShowPathBar = true;
          ShowRemovableMediaOnDesktop = true;
          ShowStatusBar = true;
          _FXSortFoldersFirst = true;
        };
        "com.apple.ImageCapture" = {
          disableHotPlug = true;
        };
        "com.apple.LaunchServices" = {
          LSQuarantine = true;
        };
        "com.apple.Siri".StatusMenuVisible = false;
        "com.apple.screensaver" = {
          askForPassword = true;
          askForPasswordDelay = 300; # seconds (5 minutes)
        };
        "com.apple.screencapture" = {
          disable-shadow = true;
          location = "~/Downloads";
          type = "png";
        };
        "com.apple.spaces"."spans-displays" = 0;
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0;
          HideDesktop = 0;
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

  security.pam.services.sudo_local.touchIdAuth = true;

  nix.enable = false;
  programs.zsh.enable = true;

  environment = {
    shells = [pkgs.zsh];
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
