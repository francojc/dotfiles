{
  description = "Nix for macOS, NixOS, and Omarchy (Arch Linux) configuration";
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
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };
    determinate = {
      url = "github:DeterminateSystems/determinate";
    };
    virby = {
      url = "github:quinneden/virby-nix-darwin";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    #
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    darwin,
    home-manager,
    nix-flatpak,
    determinate,
    virby,
    ...
  }: let
    # Import system definitions and host configurations
    systemLib = import ./lib/systems.nix;

    # Load host configurations
    hosts = {
      "Macbook-Airborne" = import ./hosts/Macbook-Airborne/default.nix;
      "Mac-Minicore" = import ./hosts/Mac-Minicore/default.nix;
      "Mini-Rover" = import ./hosts/Mini-Rover/default.nix;
      "nixos-quattro" = import ./hosts/nixos-quattro/default.nix;
      "omarchy" = import ./hosts/omarchy/default.nix;
    };

    # Special args shared by every builder. `isArch` distinguishes an Omarchy
    # user environment from a NixOS host that happens to share the same
    # nixpkgs `system` (aarch64-linux). `isLinux` stays true for Arch, because
    # it is still Linux; only the management layer differs.
    mkSpecialArgs = hostname: hostConfig: isArch: let
      systemInfo = systemLib.supportedSystems.${hostConfig.system};
    in
      inputs
      // {
        inherit self hostname isArch;
        username = hostConfig.username;
        useremail = hostConfig.useremail;
        themeName = hostConfig.theme;
        isDarwin = systemInfo.platform == "darwin";
        isLinux = systemInfo.platform == "linux";
      };

    # Home Manager configuration used by the nix-darwin/NixOS system builders.
    mkHomeManagerConfig = hostname: hostConfig: {
      useGlobalPkgs = true;
      useUserPackages = true;
      verbose = true;
      backupFileExtension = "backup";
      extraSpecialArgs = mkSpecialArgs hostname hostConfig false;
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
      ./modules/shared/overlays.nix
      ./modules/shared/fonts.nix
      ./modules/shared/nix-core.nix
      ./modules/shared/packages.nix
    ];

    # Build a nix-darwin or NixOS system configuration.
    mkSystemConfig = hostname: hostConfig: let
      systemInfo = systemLib.supportedSystems.${hostConfig.system};
      specialArgs = mkSpecialArgs hostname hostConfig false;
    in
      if systemInfo.platform == "darwin"
      then
        # Darwin system configuration
        darwin.lib.darwinSystem {
          system = hostConfig.system;
          specialArgs = specialArgs;
          modules =
            commonModules
            ++ [
              # Darwin-specific modules
              ./modules/darwin/apps.nix
              # Rosetta Linux builder (bootstraps via Determinate native Linux builder)
              # nix-rosetta-builder.darwinModules.default
              # {
              #   nix-rosetta-builder.onDemand = true;
              # }
              # Home Manager integration for Darwin
              home-manager.darwinModules.home-manager
              {
                home-manager = mkHomeManagerConfig hostname hostConfig;
              }
            ]
            ++ hostConfig.hostModules;
        }
      else if systemInfo.platform == "linux"
      then
        # NixOS system configuration
        nixpkgs.lib.nixosSystem {
          system = hostConfig.system;
          specialArgs = specialArgs;
          modules =
            commonModules
            ++ [
              # NixOS-specific modules
              ./modules/nixos/apps.nix

              # nix-flatpak system module
              nix-flatpak.nixosModules.nix-flatpak

              # Home Manager integration for NixOS
              home-manager.nixosModules.home-manager
              {
                home-manager = mkHomeManagerConfig hostname hostConfig;
              }
            ]
            ++ hostConfig.hostModules;
        }
      else throw "Unsupported system: ${hostConfig.system}";

    # Build a standalone Home Manager configuration for an Arch/Omarchy host.
    #
    # Omarchy owns the OS (kernel, systemd, pacman packages, theming), so Nix
    # manages only the user environment. There is no system module list here:
    # `hostConfig.hostModules` is intentionally ignored, and only `./home`
    # plus `hostConfig.homeModules` are evaluated.
    mkHomeConfig = hostname: hostConfig: let
      systemInfo = systemLib.supportedSystems.${hostConfig.system};
    in
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${systemInfo.system};
        extraSpecialArgs = mkSpecialArgs hostname hostConfig true;
        modules =
          [
            ./home
          ]
          ++ hostConfig.homeModules;
      };

    # Helper to filter hosts by their effective platform. Uses
    # systemLib.helpers.platformOf so a host can override the platform implied
    # by its nixpkgs system (e.g. Omarchy on aarch64-linux).
    filterHostsByPlatform = platform:
      nixpkgs.lib.filterAttrs (
        _hostname: hostConfig: systemLib.helpers.platformOf hostConfig == platform
      )
      hosts;
  in {
    # Overlays for custom packages
    overlays.default = final: prev: {
      pdc-mdpdf = final.callPackage ./pkgs/pdc-mdpdf {};
    };

    # Generate Darwin configurations for Darwin hosts
    darwinConfigurations = builtins.mapAttrs mkSystemConfig (filterHostsByPlatform "darwin");

    # Generate NixOS configurations for Linux hosts
    nixosConfigurations = builtins.mapAttrs mkSystemConfig (filterHostsByPlatform "linux");

    # Generate standalone Home Manager configurations for Arch/Omarchy hosts
    homeConfigurations = builtins.mapAttrs mkHomeConfig (filterHostsByPlatform "arch");

    # Formatters for supported systems
    formatter =
      nixpkgs.lib.genAttrs
      (builtins.attrNames systemLib.supportedSystems)
      (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
