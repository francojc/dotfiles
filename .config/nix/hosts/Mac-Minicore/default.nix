# Host-specific configuration for Mac-Minicore
#
# Thin macOS host: system defaults, the LLM servers (Metal stays on macOS) and
# a try-omarchy VM (Omarchy-Mini) that does the real work.
{
  # System configuration
  system = "aarch64-darwin";

  # User configuration
  username = "jeridf";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "gruvbox"; # options: arthur, ayu, blackmetal, catppuccin, gruvbox, iceberg, kanso, nightfox, onedark, tender, tokyonight, vague, vscode

  # Host-specific modules
  hostModules = [
    ../../profiles/darwin/base.nix
    ../../profiles/darwin/minimal.nix
    ../../profiles/darwin/llm-host.nix

    # Inline module for host-specific configuration
    {
      system.keyboard = {
        userKeyMapping = [
          {
            HIDKeyboardModifierMappingSrc = 1095216660483; # Fn key
            HIDKeyboardModifierMappingDst = 30064771302; # Right Option
          }
        ];
      };
    }
  ];

  # Home Manager modules (see roles/default.nix)
  homeModules = (import ../../roles).mac;
}
