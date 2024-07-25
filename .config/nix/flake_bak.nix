# ~/.config/nix/flake.nix
{
  description = "My Darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # Set up touch id for sudo
      security.pam.enableSudoTouchIdAuth = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.home-manager
          pkgs.neofetch 
          pkgs.tree
          pkgs.vim 
          pkgs.git
          pkgs.htop
          pkgs.kitty
          pkgs.neovim
          pkgs.ripgrep
          pkgs.taskwarrior
          pkgs.taskwarrior-tui
          pkgs.fd
          pkgs.zsh
          pkgs.eza
          pkgs.fzf
          pkgs.abook
          pkgs.atuin
          pkgs.datasette
          pkgs.pandoc
          pkgs.isync
          pkgs.jq
          pkgs.luajit
          pkgs.luajitPackages.luarocks
          pkgs.llm
          pkgs.m-cli
          pkgs.lynx
          pkgs.mas
          pkgs.notmuch
          pkgs.msmtp
          pkgs.neomutt
          pkgs.nodejs
          pkgs.oh-my-posh
          pkgs.pianobar
          pkgs.python3
          pkgs.python312Packages.radian
          pkgs.R
          pkgs.sqlite
          pkgs.stow
          pkgs.xclip
          pkgs.yazi-unwrapped
          pkgs.zoxide
          pkgs.zsh-syntax-highlighting
          pkgs.zsh-vi-mode
          pkgs.lazydocker
          pkgs.lazygit
          pkgs.skhd
          pkgs.wezterm
          pkgs.yabai

          ];

      environment.variables.HOMEBREW_NO_ANALYTICS = "1";

      # Enable brew package manager for casks primarily
      homebrew = {
          enable = true;
          onActivation = {
            autoUpdate = true;
            cleanup = "zap";
            upgrade = true;
          };
          taps = [];
          brews = [
            "coreutils"
          ];
          casks = [
            "appcleaner"
            "arc"
            "audacity"
            "bettermouse"
            "bitwarden"
            "calibre"
            "datasette"
            "docker"
            "drawio"
            "dropbox"
            "espanso"
            "font-hack"
            "font-hack-nerd-font"
            "font-meslo-lg-nerd-font"
            "font-symbols-only-nerd-font"
            "google-drive"
            "jordanbaird-ice"
            "kap"
            "mullvadvpn"
            "obsidian"
            "praat"
            "quarto"
            "raycast"
            "rectangle"
            "sequel-ace"
            "stolendata-mpv"
            "transcribe"
            "xquartz"
            "zoom"
            "zotero@beta"
           ];
          masApps = {};
        };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;

      nix = {
        package = pkgs.nix;
        gc.automatic = true;
      };


      # Create /etc/zshrc that loads the nix-darwin environment.
      programs = {
        zsh = {
          enable = true;  # default shell on catalina
          # autosuggestions.enable = true;
        };
      };
        
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Declare the user 
      users.users.francojc = {
          name = "francojc";
          home = "/Users/francojc";
        };
    };

    homeconfig = {pkgs, ...}: {
      home.stateVersion = "23.05";
      programs.home-manager.enable = true;
      # home.file = {
      #   ".zshrc".source = ./zshrc_config;
      # };
      home.packages = with pkgs; 
        [
          bat
          tldr
        ];
      home.sessionVariables = {
        EDITOR = "nvim";
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MacBook-Airborne
    darwinConfigurations."MacBook-Airborne" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
        home-manager.darwinModules.home-manager {
          # home-manager.backupFileExtension = "bak-before-nix";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.users.francojc = homeconfig;
          }
        ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."MacBook-Airborne".pkgs;
  };
}
