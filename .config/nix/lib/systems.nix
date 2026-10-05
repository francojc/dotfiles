let
  # Supported system architectures with their platform-specific details
  supportedSystems = {
    "aarch64-darwin" = {
      system = "aarch64-darwin";
      platform = "darwin";
      arch = "aarch64";
    };
    "x86_64-darwin" = {
      system = "x86_64-darwin";
      platform = "darwin";
      arch = "x86_64";
    };
    "aarch64-linux" = {
      system = "aarch64-linux";
      platform = "linux";
      arch = "aarch64";
    };
    "x86_64-linux" = {
      system = "x86_64-linux";
      platform = "linux";
      arch = "x86_64";
    };
  };

  # Helper functions for working with systems
  helpers = rec {
    # Check if a system is Darwin-based
    isDarwin = system: let
      systemInfo = supportedSystems.${system} or null;
    in
      systemInfo != null && systemInfo.platform == "darwin";

    # Check if a system is Linux-based
    isLinux = system: let
      systemInfo = supportedSystems.${system} or null;
    in
      systemInfo != null && systemInfo.platform == "linux";

    # Get all systems for a specific platform
    getSystemsForPlatform = platform:
      builtins.filter (
        system: let
          systemInfo = supportedSystems.${system} or null;
        in
          systemInfo != null && systemInfo.platform == platform
      ) (builtins.attrNames supportedSystems);

    # Get all Darwin systems
    getDarwinSystems = getSystemsForPlatform "darwin";

    # Get all Linux systems
    getLinuxSystems = getSystemsForPlatform "linux";

    # Resolve the effective platform for a host. A host may override the
    # platform implied by its nixpkgs `system`; this is how an Omarchy host
    # (Arch Linux running on an `aarch64-linux` nixpkgs system) is told apart
    # from a NixOS host that uses the same nixpkgs system.
    platformOf = host:
      if host ? platform && host.platform != null
      then host.platform
      else supportedSystems.${host.system}.platform;

    # True when a host is managed as an Arch/Omarchy user environment
    # (standalone Home Manager) rather than a NixOS/darwin system.
    isArchHost = host: platformOf host == "arch";
  };
in {
  inherit supportedSystems helpers;
}
