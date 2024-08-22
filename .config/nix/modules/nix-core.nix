{ pkgs, lib, ... }:

{
  services.nix-daemon.enable = true;
  nkgs.config.allowUnfree = true;
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
}
