{
  config,
  pkgs,
  ...
}: {
  time.timeZone = "America/New_York";

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = false;
}
