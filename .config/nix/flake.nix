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
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs"
    };
  };

  outputs = inputs @ {
    nixpkgs,
    darwin,
    home-manager,
    nvf,
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
    mkDarwinConfig = hostname: {
      username,
      useremail,
      system,
    }:
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs =
          inputs
          // {
            inherit username useremail hostname;
          };
        pkgs = import nixpkgs {
          inherit system;
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
              extraSpecialArgs =
                inputs
                // {
                  inherit username useremail hostname;
                };
              users.${username} = {
                imports = [
                  ./home/default.nix
                  nvf.homeManagerModules.default
                ];
              };
            };
          }
        ];
      };
  in {
    darwinConfigurations = builtins.mapAttrs mkDarwinConfig systems; # nix code formatter
    formatter."aarch64-darwin" = nixpkgs.legacyPackages."aarch64-darwin".alejandra;
  };
}
