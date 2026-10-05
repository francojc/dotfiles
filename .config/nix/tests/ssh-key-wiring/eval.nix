let
  hosts = ["Macbook-Airborne" "Mac-Minicore" "Mini-Rover" "nixos-quattro" "future-host"];
  lib = {
    optionalAttrs = condition: attrs:
      if condition
      then attrs
      else {};
    optional = condition: value:
      if condition
      then [value]
      else [];
  };
  evaluate = hostname: let
    module = import ../../home/ssh-aliases.nix {inherit hostname lib;};
    registry = module.xdg.configFile."ssh/keys.yaml";
  in {
    paths = import ../../home/ssh-key-paths.nix {inherit hostname;};
    config = module.home.file.".ssh/config.d/nix-managed.conf".text;
    environment = module.home.sessionVariables;
    warnings = module.warnings;
    registryExists = builtins.pathExists registry.source;
    registrySourceCorrect = registry.source == ../../../ssh/keys.yaml;
    registryForce = registry.force;
  };
in
  builtins.listToAttrs (map (hostname: {
      name = hostname;
      value = evaluate hostname;
    })
    hosts)
