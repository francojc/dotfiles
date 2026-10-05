# Inventory and cutover readiness are separate. Change readiness only after
# approved provisioning/migration establishes usable paths and rollback access.
{hostname}: let
  devices = {
    "Macbook-Airborne" = {
      nickname = "airborne";
      provisioning = "inventoried";
      ready = {
        # Pair renamed with approved old-path links; activation still pending.
        forgejo = true;
        codeberg = false;
        workstations = false;
      };
    };
    "Mac-Minicore" = {
      nickname = "minicore";
      provisioning = "unprovisioned";
      ready = {
        forgejo = false;
        codeberg = false;
        workstations = false;
      };
    };
    "Mini-Rover" = {
      nickname = "rover";
      provisioning = "unprovisioned";
      ready = {
        forgejo = false;
        codeberg = false;
        workstations = false;
      };
    };
    "nixos-quattro" = {
      nickname = "quattro";
      provisioning = "unprovisioned";
      ready = {
        forgejo = false;
        codeberg = false;
        workstations = false;
      };
    };
  };
  device = devices.${hostname} or null;
  legacy = {
    forgejo = "~/.ssh/id_ed25519_forgejo";
    codeberg = "~/.ssh/id_ed25519_codeberg";
    workstations = "~/.ssh/id_ed25519_workstation";
  };
  services =
    builtins.mapAttrs (
      purpose: current: let
        intended =
          if device == null
          then null
          else "~/.ssh/id_ed25519_${device.nickname}_${purpose}";
        ready = device != null && device.provisioning == "inventoried" && device.ready.${purpose};
      in {
        inherit current intended ready;
        selected =
          if ready
          then intended
          else current;
      }
    )
    legacy;
in {
  inherit services;
  nickname =
    if device == null
    then null
    else device.nickname;
  provisioning =
    if device == null
    then "unsupported"
    else device.provisioning;
}
