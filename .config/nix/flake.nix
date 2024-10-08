{
  description = "Nix for macOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # main nixpkgs repo
    darwin = {
      url = "github:lnl7/nix-darwin"; # darwin repo
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager"; # home manager repo
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim"; # nixvim repo
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , darwin
    , home-manager
    , nixvim
    , ...
    }:
    let
      username = "francojc";
      useremail = "francojc@wfu.edu";
      system = "aarch64-darwin";
      hostname = "MacBook-Airborne";

      specialArgs =
        inputs
        // {
          inherit username useremail hostname;
        };
    in
    {
      darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
        inherit system specialArgs;
        modules = [
          ./modules/nix-core.nix
          ./modules/system.nix
          ./modules/apps.nix
          ./modules/host-users.nix

          # home manager
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              verbose = true;
              extraSpecialArgs = specialArgs;
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

      # nix code formatter
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    };
}
