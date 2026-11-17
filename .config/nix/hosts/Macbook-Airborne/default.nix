# Host-specific configuration for Macbook-Airborne
#
# Thin macOS host. Runs only the Copilot API proxy; local model servers live on
# Mac-Minicore (reached over Tailscale). Real tooling lives on Omarchy-Air.
{
  # System configuration
  system = "aarch64-darwin";

  # User configuration
  username = "francojc";
  useremail = "francojc@wfu.edu";

  # Theme selection for this host
  theme = "gruvbox"; # options: arthur, ayu, blackmetal, catppuccin, gruvbox, iceberg, kanso, nightfox, onedark, tender, tokyonight, vague, vscode

  # Host-specific modules
  hostModules = [
    ../../profiles/darwin/base.nix
    ../../profiles/darwin/minimal.nix
    ../../modules/darwin/determinate.nix
    ../../modules/darwin/copilot-api.nix
    {
      custom.services.copilotApi.enable = true;
    }
  ];

  # Home Manager modules (see roles/default.nix)
  homeModules = (import ../../roles).mac;
}
