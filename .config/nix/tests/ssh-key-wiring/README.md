# SSH Home Manager wiring tests

Run from any directory:

```bash
bash .config/nix/tests/ssh-key-wiring/run.sh
```

Five isolated evaluation groups cover Airborne, Minicore, Rover, Quattro, and unsupported host. Require Nix and Python 3; no dependency downloads, activation, key inspection, agent interaction, or network operations. Tests verify explicit nickname/provisioning mappings, per-service readiness, current versus intended paths, environment settings, registry source location and existence, `force = false`, Airborne-only registry management exclusion, readiness warnings, and every SSH block's exact directives. Only approved Airborne Forgejo readiness is true; proposed Forgejo identity uses renamed path. All other devices/services retain legacy selection. This declaration does not claim activation completed. Generic tailnet hosts retain default/agent identity selection.

Full Home Manager evaluation also requires cached flake inputs. Before new files are tracked, ordinary Git-backed flake evaluation excludes them. Evaluate a repository-root path snapshot instead; choosing only `.config/nix` as snapshot root loses sibling `.config/ssh/keys.yaml`:

```bash
repo=$(git rev-parse --show-toplevel)
nix eval --offline --impure --json \
  --expr "builtins.getFlake \"path:$repo?dir=.config/nix\"" \
  --apply 'f: builtins.mapAttrs (_: system: builtins.mapAttrs (_: hm: {
    device = hm.home.sessionVariables.SSH_KEY_AUDIT_DEVICE;
    ssh = hm.home.file.".ssh/config.d/nix-managed.conf".text;
    registryExists = builtins.pathExists hm.xdg.configFile."ssh/keys.yaml".source;
    force = hm.xdg.configFile."ssh/keys.yaml".force;
    registryEnabled = hm.xdg.configFile."ssh/keys.yaml".enable;
    warnings = hm.warnings;
  }) system.config.home-manager.users) (f.darwinConfigurations // f.nixosConfigurations)'
```

Path snapshot copies repository content into Nix store. Run only on reviewed dotfiles repository; never point evaluation at HOME or private SSH storage. Registry contains public metadata only. This command evaluates selected options, not activation derivations or full system builds. Nothing activates generated configuration. Full build, native Linux execution, and live collision/backup behavior remain outside these tests.
