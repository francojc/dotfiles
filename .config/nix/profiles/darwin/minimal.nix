# Minimal macOS host profile, shared by Mac-Minicore and Macbook-Airborne.
#
# The Macs are thin hosts now: real tooling lives on the Omarchy hosts
# (Omarchy-Air natively, Omarchy-Mini in a try-omarchy VM). Only keep here:
#   - formulae with no aarch64-linux nixpkgs package (macOS-only tools)
#   - `node`, which the copilot-api launchd service and npm-global tools use
#     (the only Node on the Macs; nixpkgs nodejs is not installed here)
#   - GUI apps as casks (land in /Applications, so Spotlight indexes them):
#     caffeine, helium-browser, kitty, orbstack
# `cleanup = "zap"` is on, so removing an entry uninstalls it and its data.
# Host-specific entries live in each host's default.nix / profiles.
#
# Both Macs run Determinate Nix as the installer/daemon, so both import the
# Determinate module (it forces `nix.enable = false` and owns
# /etc/nix/nix.custom.conf).
{pkgs, ...}: {
  imports = [
    ../../modules/darwin/determinate.nix
  ];

  environment.systemPackages = with pkgs; [
    coreutils-prefixed # GNU coreutils with g-prefix (avoids shadowing BSD commands)
    gcal # GNU cal command
    terminal-notifier # macOS notifications from command line
    avahi # mDNS/ DNS-SD service discovery
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
      extraEnv = {
        HOMEBREW_NO_ANALYTICS = "1";
        HOMEBREW_NO_ENV_HINTS = "1";
      };
      extraFlags = [];
    };

    taps = [
      {
        name = "felixkratz/formulae"; # borders
        trusted = true;
      }
      {
        name = "keith/formulae"; # reminders-cli
        trusted = true;
      }
      {
        name = "ashuttl/linecast"; # linecast
        trusted = true;
      }
    ];

    brews = [
      "borders" # jankyborders (macOS only)
      "linecast" # TUI weather (not in the locked nixpkgs; move to Nix after the next flake update)
      "mole" # terminal cleanup app for macOS
      "node" # Node.js; copilot-api launchd service and npm-global tools need it
      "pngpaste" # paste images (macOS only)
      "reminders-cli" # cli interface to macOS Reminders
    ];

    casks = [
      "caffeine" # menu bar keep-awake
      "helium-browser" # browser (ungoogled-chromium)
      "kitty" # terminal; also links /opt/homebrew/bin/{kitty,kitten}. Config: home/kitty.nix
      "orbstack" # Docker/Linux containers
    ];
  };
}
