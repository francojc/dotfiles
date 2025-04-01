{
  description = "Nix for macOS configuration";
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    darwin,
    home-manager,
    ...
  }: let
    # Machine configurations
    systems = {
      "Macbook-Airborne" = {
        username = "francojc";
        useremail = "francojc@wfu.edu";
        system = "aarch64-darwin";
      };
      "Mac-Minicore" = {
        username = "jeridf";
        useremail = "francojc@wfu.edu";
        system = "aarch64-darwin";
      };
    };
    # Corrected function signature to accept name and value from mapAttrs
    mkDarwinConfig = hostname: systemAttrs:
      darwin.lib.darwinSystem {
        system = systemAttrs.system; # Use system from the attribute set value
        specialArgs =
          inputs
          // {
            # Pass arguments from the function parameters
            inherit hostname;
            username = systemAttrs.username;
            useremail = systemAttrs.useremail;
          };
        pkgs = import nixpkgs {
          system = systemAttrs.system; # Use system from the attribute set value
          config.allowUnfree = true;
        };
        modules = [
          ./modules/nix-core.nix
          ./modules/system.nix
          ./modules/apps.nix
          ./modules/host-users.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              verbose = true;
              # Modified extraSpecialArgs structure
              extraSpecialArgs = {
                inherit inputs; # Pass flake inputs as 'inputs' attribute
                inherit hostname; # Pass hostname
                username = systemAttrs.username; # Pass username
                useremail = systemAttrs.useremail; # Pass useremail
              };
              # Use username from the attribute set value
              users.${systemAttrs.username} = {
                imports = [
                  inputs.nixCats.homeModule # Import nixCats module here
                  ./home/default.nix
                ];
              };
            };
          }
        ];
      };
  in {
    # mapAttrs calls mkDarwinConfig with hostname (name) and systemAttrs (value)
    darwinConfigurations = builtins.mapAttrs mkDarwinConfig systems;
    formatter."aarch64-darwin" = nixpkgs.legacyPackages."aarch64-darwin".alejandra;
  };
}
