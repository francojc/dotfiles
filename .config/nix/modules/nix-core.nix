{ pkgs, lib, config, ... }: {
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
    # nix-daemon.enable = true;
    tailscale.enable = true;
  };
}
