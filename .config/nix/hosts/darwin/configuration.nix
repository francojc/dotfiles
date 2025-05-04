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

  system.stateVersion = "24.05"; # Keep consistent

  system = {
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

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
          "/Applications/Zen Browser.app"
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

  environment.variables.HOMBREW_NO_ANALYTICS = "1"; # Keep brew specific var

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [
      "homebrew/services"
      "FelixKratz/formulae" # for jankyborders
      "nao1215/tap" # for sqly
      "pomdtr/tap" # for sunbeam
    ];

    brews = [
      "borders" # jankyborders
      "huggingface-cli"
      "npm"
      "keith/formulae/reminders-cli"
      "ollama"
      "python@3.11"
      "rename"
      "speedtest-cli"
      "sunbeam"
      "sqly"
      "wget"
    ];

    casks = [
      "appcleaner" # remove macOS apps
      "betterdisplay" # display tweaks
      "bettermouse" # mouse tweaks
      "claude" #
      "dropbox"
      "ghostty@tip"
      "google-drive"
      "kap" # screen recording
      "memory-cleaner"
      "mullvadvpn"
      "obsidian"
      "orbstack" # Docker alternative
      "parallels" # virtualization
      "raycast"
      "rectangle"
      "rocket" # emoji picker
      "signal" # messaging
      "transcribe"
      "transmission"
      "visual-studio-code"
      "yaak" # API client
      "zen-browser"
      "zoom"
      "zotero@beta"
    ];

    masApps = {
      GarageBand = 682658836;
      # iMovie = 408981434;
      # Adblock_Plus = 1432731683;
      # AudioBookBinder = 413969927;
      Bitwarden = 1352778147;
      # Dark_Reader_for_Safari = 1438243180;
      IPA_Keyboard = 1461264628;
      # JustFocus = 1142151959;
      # LittleSnitchMini = 1629008763;
      # Kagi_for_Safari = 1622835804;
      Keynote = 409183694;
      Numbers = 409203825;
      Pages = 409201541;
      # Suggester = 1106482294;
      Triode = 1450027401;
      # Vimari = 1480933944;
      # Vinegar_for_Safari = 1591303229;
      # VoiceType = 6736525125;
      iPreview = 1519213509;
    };
  };
}
