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
    isDarwin = system: 
      let systemInfo = supportedSystems.${system} or null;
      in systemInfo != null && systemInfo.platform == "darwin";

    # Check if a system is Linux-based  
    isLinux = system:
      let systemInfo = supportedSystems.${system} or null;
      in systemInfo != null && systemInfo.platform == "linux";

    # Get all systems for a specific platform
    getSystemsForPlatform = platform:
      builtins.filter (system: 
        let systemInfo = supportedSystems.${system} or null;
        in systemInfo != null && systemInfo.platform == platform
      ) (builtins.attrNames supportedSystems);

    # Get all Darwin systems
    getDarwinSystems = getSystemsForPlatform "darwin";

    # Get all Linux systems
    getLinuxSystems = getSystemsForPlatform "linux";
  };

in {
  inherit supportedSystems helpers;
}