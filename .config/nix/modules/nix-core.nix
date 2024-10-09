{ pkgs, ... }: {
  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = false;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
  services.nix-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;


}
