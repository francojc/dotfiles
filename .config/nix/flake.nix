# ~/.config/nix/flake.nix
{
  description = "My Darwin, Hombrew, and Home configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    nixvim.url = "github:nix-community/nixvim";
  };
  
  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nixvim, ...}:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      overlays = import ./overlays.nix;
    in
    {
      nixpkgs.overlaps = [ overlays ];
      darwinConfigurations."MacBook-Airborne" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit self; };
        modules = [
          ./darwin/config.nix
          ./user/config.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.francojc = {
              imports = [
                ./home/config.nix
                nixvim.homeManagerModules.nixvim
              ];
            };
          }
        ];
      };

      darwinPackages = self.darwinConfigurations."MacBook-Airborne".pkgs;
    };
}
