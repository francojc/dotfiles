# ~/.config/nix/flake.nix
{
  description = "My Darwin, Hombrew, and Home configuration";

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
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    darwinConfigurations."MacBook-Airborne" = nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit self; };
      modules = [
        ({ pkgs, ... }: {
           _module.args.self = self;
        })
        ./darwin/config.nix
        ./user/config.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.users.francojc = import ./home/config.nix;
        }
      ];
    };

    darwinPackages = self.darwinConfigurations."MacBook-Airborne".pkgs;
  };
}
