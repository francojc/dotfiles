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
          secret_key = "7a1937f3e3a6205382ec7427e3439e0533b7902962c5769fe641148a6aebcf25";  # Generate with: openssl rand -hex 32
        };
      };
    };
    tailscale.enable = true;
  };
}
