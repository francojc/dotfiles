{
  description = "Nix for macOS configuration";

  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    # INFO: consider where to put this
    # nixvim = {
    #   url = "github:nix-community/nixvim";
    # };
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , darwin
    , home-manager
      # , nixvim # INFO: add my config here before building
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
              extraSpecialArgs = specialArgs;
              users.${username} = import ./home/default.nix;
            };
          }
        ];
      };

      # nix code formatter
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    };
}
