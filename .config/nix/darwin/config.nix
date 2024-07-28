# ~/.config/nix/darwin/config.nix
{ config, pkgs, self, ... }: {
  imports = [
    ./packages.nix
    ./homebrew.nix
  ];
  
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nix;
    gc.automatic = true;
    settings = {
      experimental-features = "nix-command flakes";
    };
  };
  
  services.nix-daemon.enable = true;

  environment.variables.HOMEBREW_NO_ANALYTICS = "1";

  programs.zsh.enable = true;

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 4;
  security.pam.enableSudoTouchIdAuth = true;
}
