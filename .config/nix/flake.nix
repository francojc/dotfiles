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
          # home-manager.darwinModules.home-manager
          # {
          #   home-manager = {
          #     useGlobalPkgs = true;
          #     useUserPackages = true;
          #     verbose = true;
          #     extraSpecialArgs = specialArgs;
          #     users.${username} = {
          #       imports = [
          #         ./home
          #         nixvim.homeManagerModules.nixvim
          #       ];
          #     };
          #   };
          # }
        ];
      };

      # nix code formatter
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    };
}
