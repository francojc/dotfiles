let
  hosts = ["Macbook-Airborne" "Mac-Minicore" "Mini-Rover" "omarchy" "nixos-quattro" "future-host"];
  lib = {
    concatMapStringsSep = separator: f: values:
      builtins.concatStringsSep separator (map f values);
    optionalAttrs = condition: attrs:
      if condition
      then attrs
      else {};
    optionalString = condition: value:
      if condition
      then value
      else "";
  };
  evaluate = hostname: let
    module = import ../../home/ssh-aliases.nix {inherit hostname lib;};
    registry = module.xdg.configFile."ssh/keys.yaml";
  in {
    paths = import ../../home/ssh-key-paths.nix {inherit hostname;};
    config = module.home.file.".ssh/config.d/nix-managed.conf".text;
    environment = module.home.sessionVariables;
    warnings = module.warnings or [];
    registryExists = builtins.pathExists registry.source;
    registrySourceCorrect = registry.source == ../../home/ssh-keys.yaml;
    registryForce = registry.force;
    registryEnabled = registry.enable or true;
  };
in
  builtins.listToAttrs (map (hostname: {
      name = hostname;
      value = evaluate hostname;
    })
    hosts)
