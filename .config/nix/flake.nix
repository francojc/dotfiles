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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    darwin,
    home-manager,
    ...
  }: let
    # Import system definitions and host configurations
    systemLib = import ./lib/systems.nix;

    # Load host configurations
    hosts = {
      "Macbook-Airborne" = import ./hosts/Macbook-Airborne/default.nix;
      "Mac-Minicore" = import ./hosts/Mac-Minicore/default.nix;
      "Nix-Rover" = import ./hosts/Nix-Rover/default.nix;
    };

    # Unified configuration builder for both Darwin and NixOS
    mkSystemConfig = hostname: hostConfig: let
      systemInfo = systemLib.supportedSystems.${hostConfig.system};
      isDarwin = systemInfo.platform == "darwin";
      isLinux = systemInfo.platform == "linux";

      # Common special args passed to all modules
      commonSpecialArgs =
        inputs
        // {
          inherit hostname;
          username = hostConfig.username;
          useremail = hostConfig.useremail;
          inherit isDarwin isLinux;
        };

      # Common Home Manager configuration
      homeManagerConfig = {
        useGlobalPkgs = true;
        useUserPackages = true;
        verbose = true;
        extraSpecialArgs = commonSpecialArgs;
        users.${hostConfig.username} = {
          imports =
            [
              ./home
            ]
            ++ hostConfig.homeModules;
        };
      };

      # Common system modules (shared between Darwin and NixOS)
      commonModules = [
        ./modules/shared/fonts.nix
        ./modules/shared/nix-core.nix
        ./modules/shared/packages.nix
      ];
    in
      if isDarwin
      then
        # Darwin system configuration
        darwin.lib.darwinSystem {
          system = hostConfig.system;
          specialArgs = commonSpecialArgs;
          modules =
            commonModules
            ++ [
              # Darwin-specific modules
              ./modules/darwin/apps.nix

              # Home Manager integration for Darwin
              home-manager.darwinModules.home-manager
              {
                home-manager = homeManagerConfig;
              }
            ]
            ++ hostConfig.hostModules;
        }
      else if isLinux
      then
        # NixOS system configuration
        nixpkgs.lib.nixosSystem {
          system = hostConfig.system;
          specialArgs = commonSpecialArgs;
          modules =
            commonModules
            ++ [
              # NixOS-specific modules
              ./modules/nixos/apps.nix

              # Home Manager integration for NixOS
              home-manager.nixosModules.home-manager
              {
                home-manager = homeManagerConfig;
              }
            ]
            ++ hostConfig.hostModules;
        }
      else throw "Unsupported system: ${hostConfig.system}";

    # Helper to filter hosts by platform
    filterHostsByPlatform = platform:
      nixpkgs.lib.filterAttrs (
        hostname: hostConfig: let
          systemInfo = systemLib.supportedSystems.${hostConfig.system};
        in
          systemInfo.platform == platform
      )
      hosts;
  in {
    # Generate Darwin configurations for Darwin hosts
    darwinConfigurations = builtins.mapAttrs mkSystemConfig (filterHostsByPlatform "darwin");

    # Generate NixOS configurations for Linux hosts
    nixosConfigurations = builtins.mapAttrs mkSystemConfig (filterHostsByPlatform "linux");

    # Formatters for supported systems
    formatter =
      nixpkgs.lib.genAttrs
      (builtins.attrNames systemLib.supportedSystems)
      (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
