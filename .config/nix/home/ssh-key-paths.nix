# Declarative paths only. Generate keys locally and register public keys before
# activation; Nix never reads key material or checks runtime file existence.
{hostname}: let
  devices = {
    "Macbook-Airborne" = "airborne";
    "Mac-Minicore" = "minicore";
    "Mini-Rover" = "rover";
    "omarchy" = "omarchy";
  };
  nickname = devices.${hostname} or null;
in {
  inherit nickname;
  services =
    if nickname == null
    then {}
    else builtins.listToAttrs (map (purpose: {
      name = purpose;
      value = "~/.ssh/id_ed25519_${nickname}_${purpose}";
    }) ["forgejo" "codeberg" "github"]);
}
