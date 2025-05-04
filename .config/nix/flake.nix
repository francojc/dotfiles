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
    self,
    nixpkgs,
    darwin,
    home-manager,
    nixCats,
    ...
  }: let
    # Define all systems centrally
    allSystems = {
      "Macbook-Airborne" = {
        type = "darwin";
        system = "aarch64-darwin";
        username = "francojc";
        useremail = "francojc@wfu.edu";
      };
      "Mac-Minicore" = {
        type = "darwin";
        system = "aarch64-darwin";
        username = "jeridf";
        useremail = "francojc@wfu.edu";
      };
      # --- ADD YOUR NixOS HOST HERE ---
      "nixos" = {
        # <--- Replace with your actual NixOS hostname
        type = "nixos";
        system = "aarch64-linux";
        username = "francojc"; # <--- Replace with your NixOS username
        useremail = "francojc@wfu.edu"; # <--- Replace with your email
        configFile = ./hosts/nixos/configuration.nix; # <--- Adjust path if hostname differs
      };
    };

    # Helper to filter systems by type
    filterSystems = type: builtins.filterAttrs (name: value: value.type == type) allSystems;

    # --- Helper function for Darwin ---
    mkDarwinConfig = hostname: systemAttrs:
      darwin.lib.darwinSystem {
        system = systemAttrs.system;
        specialArgs =
          inputs
          // {
            inherit hostname;
            username = systemAttrs.username;
            useremail = systemAttrs.useremail;
            isLinux = false;
            isDarwin = true;
          };
        modules = [
          # Import relevant shared/darwin system modules
          ./modules/shared/nix-core.nix
          ./modules/darwin/system.nix
          ./modules/darwin/apps.nix
          ./modules/darwin/host-users.nix

          # Integrate Home Manager for Darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              verbose = true;
              extraSpecialArgs = {
                inherit inputs hostname;
                username = systemAttrs.username; # Pass username
                useremail = systemAttrs.useremail; # Pass useremail
                isLinux = false; # Pass down to HM config
                isDarwin = true;
              };
              users.${systemAttrs.username} = {
                imports = [
                  nixCats.homeModules.default # Use the nixCats HM module
                  ./home # Import shared home config entrypoint
                  # Add host-specific HM config here if needed:
                  # ./hosts/${hostname}/home.nix
                ];
              };
            };
          }
        ];
      };

    # --- Helper function for NixOS ---
    mkNixosConfig = hostname: systemAttrs:
      nixpkgs.lib.nixosSystem {
        system = systemAttrs.system;
        specialArgs =
          inputs
          // {
            inherit hostname;
            username = systemAttrs.username;
            useremail = systemAttrs.useremail;
            isLinux = true;
            isDarwin = false;
          };
        modules = [
          # Import the host's main configuration.nix
          systemAttrs.configFile
          # Integrate Home Manager for NixOS
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              verbose = true;
              extraSpecialArgs = {
                inherit inputs hostname;
                username = systemAttrs.username;
                useremail = systemAttrs.useremail;
                isLinux = true;
                isDarwin = false;
              };
              users.${systemAttrs.username} = {
                imports = [
                  nixCats.homeModules.default # Use the nixCats HM module
                  ./home # Import shared home config entrypoint
                  # Add host-specific HM config here if needed:
                  # ./hosts/${hostname}/home.nix
                ];
              };
            };
          }
        ];
      };
  in {
    darwinConfigurations = builtins.mapAttrs mkDarwinConfig (filterSystems "darwin");
    nixosConfigurations = builtins.mapAttrs mkNixosConfig (filterSystems "nixos");

    # Keep formatters
    formatter."aarch64-darwin" = nixpkgs.legacyPackages."aarch64-darwin".alejandra;
    formatter."aarch64-linux" = nixpkgs.legacyPackages."aarch64-linux".alejandra;
  };
}
