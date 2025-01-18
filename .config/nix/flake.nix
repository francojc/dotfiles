{
  description = "Nix for macOS configuration";

  inputs = {
    # Add nixpkgs unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Add darwin
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Add home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Add nixvim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, darwin, home-manager, nixvim, ... }:
    let
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
      mkDarwinConfig = hostname: {username, useremail, system}: darwin.lib.darwinSystem {
        inherit system;
        specialArgs = inputs // {
          inherit username useremail hostname;
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
              extraSpecialArgs = inputs // {
                inherit username useremail hostname;
              };
              users.${username} = {
                imports = [
                  ./home
                  nixvim.homeManagerModules.nixvim
                ];
              };
            };
          }
        ];
      };
    in
    {
      darwinConfigurations = builtins.mapAttrs mkDarwinConfig systems;      # nix code formatter
      formatter."aarch64-darwin" = nixpkgs.legacyPackages."aarch64-darwin".alejandra;
    };
}
