{
  pkgs,
  username,
  hostname,
  ...
}: {
  imports = [
    ../../modules/shared/nix-core.nix
  ];

  networking.hostName = hostname;
  networking.computerName = hostname;

  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [username];

  # Add this line to disable nix-darwin's Nix management
  nix.enable = false;

  system.stateVersion = 5; # Keep consistent with nix-darwin requirements

  system = {
    primaryUser = username; # Set the primary user for user-specific options

    defaults = {
      smb.NetBIOSName = hostname;

      ActivityMonitor.IconType = 5;

      menuExtraClock = {
        Show24Hour = true;
        ShowAMPM = false;
        ShowDate = 1;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        expose-group-apps = true;
        orientation = "bottom";
        persistent-apps = [
          "/Applications/Zen.app"
          "/Applications/Ghostty.app"
          "/System/Applications/Utilities/Screen Sharing.app"
        ];
        persistent-others = [
          "/Users/${username}/"
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
        FXPreferredViewStyle = "clmv";
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

  environment.variables.HOMBREW_NO_ANALYTICS = "1"; # Keep brew specific var
}
