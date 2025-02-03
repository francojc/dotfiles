{ pkgs, ... }: {
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  system = {
    stateVersion = 5;
  };
  services = {
    nix-daemon.enable = true;
    searxng = {
      enable = true;
      settings = {
        general = {
          debug = false;
          instance_name = "My SearXNG";
          secret_key = "@REPLACE_ME_WITH_A_SECRET_KEY@";  # Generate with: openssl rand -hex 32
        };
      };
    };
    tailscale.enable = true;
  };
}
