{ pkgs, ... }: {
  nix = {
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
    tailscale.enable = true;
  };
}
