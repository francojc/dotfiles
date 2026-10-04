# SSH key registry contract

Status: version 1 contract defined in Phase 1; read-only validator and audit implemented in Phase 2; Airborne baseline and registry draft populated in Phase 3. This directory contains metadata only. No live keys generated, moved, or deployed.

Phase 3 artifacts: `keys.yaml`, sanitized `baseline-airborne.json`, and `baseline-airborne.md`. Six Airborne pairs match; all six software keys usable with empty passphrase. Other devices remain unprovisioned. Registry awaits owner review before commit/sharing; runtime deployment deferred. Baseline report documents findings, provisional labels, inferred authorization scope, and operational gates.

## Locations and precedence

- Canonical registry: `.config/ssh/keys.yaml` relative to the dotfiles repository root; Airborne draft populated in Phase 3, not deployed.
- Runtime registry: `${XDG_CONFIG_HOME:-$HOME/.config}/ssh/keys.yaml`.
- Registry selection: `--registry PATH` → nonempty `SSH_KEYS_REGISTRY` → runtime default.
- SSH directory selection: `--ssh-dir PATH` → nonempty `SSH_DIR` → `$HOME/.ssh`.
- Device selection: `--device NICKNAME` → nonempty `SSH_KEY_AUDIT_DEVICE` → normalized local hostname.
- Explicit empty CLI values are argument errors. Explicit unknown device nicknames are errors; an unmatched automatically discovered hostname is informational and skips device-specific missing-key checks.

Runtime discovery does not fall back to an undeployed repository registry. Before Phase 5 deployment, use an explicit registry path. Missing registry is an error except for `--init`, which inventories locally and emits starter YAML without requiring or modifying a registry.

## Read-only audit usage

```bash
ssh-key-audit --registry /path/to/keys.yaml --device airborne
ssh-key-audit --registry /path/to/keys.yaml --device airborne --json --strict
ssh-key-audit --ssh-dir /path/to/disposable/ssh --device test --init
```

Implementation: `.bin/ssh-key-audit`, schema validator: `.bin/ssh-key-audit-lib/validate.jq`, isolated tests: `.bin/tests/ssh-key-audit/run.sh`. Airborne registry draft populated; no registry deployed. `--init` emits starter YAML only; redirect explicitly after reviewing output. It records unknown dates/scope and no authorization destinations. Without explicit device, starter nickname is `local`; normal audits instead match registry hostname aliases. `--init` and `--json` cannot be combined. `--check-remote` is recognized but rejected until Phase 7.

Exit codes: `0` completed without errors (warnings allowed); `1` warnings under `--strict`; `2` arguments, registry, dependencies, key validation, or required-operation failure. JSON stdout contains `version`, `completed`, `device`, `errors`, `warnings`, `findings`, and `inventory` on completed runs; preflight failures emit a minimal JSON error envelope and stderr diagnostic. Finding records use `severity`, `code`, `message`, and nullable `path`. Inventory records contain public fingerprint, relative path, private-file presence, hardware flag, protection observation, and pair-matching state; presence/fingerprint alone does not prove an encrypted or hardware pair matches. No private bytes are retained or logged.

Coverage limits are findings, not silent success: all file/directory symlinks are skipped conservatively, including internal targets; `retired/` is excluded; SSH config `Include`/`IdentityFile` directives are detected but not expanded or executed. Included/external tool-managed identities require separate inventory. Failed empty-passphrase checks remain `encrypted_or_uncheckable`; hardware private derivation is never attempted. Extended ACL presence requires manual review; unavailable inspection is reported. Month-based review intervals clamp the due day to the final day of shorter months. No permissions, registry, keys, agents, or remote authorization are changed.

Phase 2 tests cover Bash 3.2/current Bash on macOS, with mocked GNU stat/ACL and hardware behavior; native Linux and physical-token verification remain coverage gaps. Shared `common` helpers are sourced without changing them; audit replaces sensitive error trapping and uses its own structured findings/exit handling.

## Device identity and provisioning

| Nickname | Nix configuration identity | Configured hostname (normalized) | Configured user |
|---|---|---|---|
| `airborne` | `Macbook-Airborne` | `macbook-airborne` | `francojc` |
| `minicore` | `Mac-Minicore` | `mac-minicore` | `jeridf` |
| `rover` | `Mini-Rover` | `mini-rover` | `jeridf` |
| `quattro` | `nixos-quattro` | `nixos-quattro` | `jeridf` |

All four identities and users are confirmed in `flake.nix` and `hosts/*/default.nix`. Shared Darwin and NixOS profiles explicitly set `networking.hostName = hostname`; Darwin also sets `networking.computerName`. These normalized names may seed configuration-backed fallback aliases. Airborne's runtime hostname is also confirmed locally; activation/runtime agreement on other devices remains unverified. Record additional aliases only after confirmation; configured names do not prove deployed state.

Home Manager receives the exact `hostname` argument through `extraSpecialArgs`; Phase 5 should use that explicit mapping for `SSH_KEY_AUDIT_DEVICE`. Hostname fallback lowercases and removes the domain suffix; no hyphen splitting. Require normalized aliases to be unique across devices.

`provisioning` records inventory state only: `unprovisioned` or `inventoried`. It does not authorize deployment and does not prove all keys exist. Per-device/per-key path cutover readiness remains explicit in Nix configuration and migration records; do not infer readiness from the desired name or provisioning field.

## YAML structure and validation

Input must be one YAML document containing JSON-compatible data. Reject duplicate mapping keys, unsupported custom tags, and malformed values before using records. Never execute YAML values as shell code. Phase 2 must test parser behavior rather than assume YAML-to-JSON conversion detects duplicate keys.

Top-level required fields are `version`, `devices`, and `keys`; reject unknown fields at every structured level to catch misspellings. Version must be integer `1`. `devices` is a mapping; `keys` is an array and may be empty for starter output. Null means unknown, not false or an empty string. Required nullable fields must still be present.

### Device fields

- Device mapping keys: lowercase nickname matching `^[a-z][a-z0-9_-]*$`.
- `hostnames`: required array of unique normalized hostname strings; may be empty when no runtime alias is confirmed.
- `provisioning`: required enum `unprovisioned` or `inventoried`.

### Key fields

| Field | Type and rule |
|---|---|
| `name` | Required nonempty filename label; desired naming convention, not current location or unique identity |
| `fingerprint` | Required OpenSSH SHA256 fingerprint: `SHA256:` followed by 43 unpadded Base64 characters; unique across records |
| `purpose` | Required lowercase label matching `^[a-z][a-z0-9_-]*$`; use `unknown` for investigation |
| `status` | Required enum `active`, `retiring`, or `retired` |
| `holders` | Required array of holder observations; may be empty for historical records |
| `created` | Required ISO date `YYYY-MM-DD` or null; real calendar date, never inferred from file timestamps |
| `review_after_months` | Required positive integer or null to disable age reminders |
| `backup` | Required descriptive string or null; never secret content, lookup command, or retrievable credential |
| `replaces` | Required fingerprint or null; non-null value must reference another record, not itself; replacement chains must be acyclic |
| `authorization_scope_complete` | Required boolean; false until owner confirms authorization coverage |
| `notes` | Required string; may be empty; metadata only |
| `authorized` | Required array of authorization destinations; may be empty when unknown |

Validate desired names as single filename components without slash, backslash, control characters, or `.`/`..`. Do not require new naming convention for unresolved legacy keys. Desired names need not be unique: replacement records may share a desired final label while using distinct actual paths.

### Holder fields

- `device`: required reference to a defined device.
- `path`: required actual relative private-key path under selected SSH directory; companion is `path + .pub`. Reject empty paths, absolute paths, backslashes, control characters, empty segments, and `.`/`..` segments. Spaces and nested directories are supported.
- `private_key_expected`: required boolean; public-only observations use false.
- `material_state`: required enum `present`, `archived`, `removed`, or `unknown`.
- `observed_at`: required ISO UTC timestamp `YYYY-MM-DDTHH:MM:SSZ` or null.

A `(device, path)` may belong to only one fingerprint record. One fingerprint may have multiple holders or paths. Multiple software private-key holders across devices are an audit security warning, not a schema error. Duplicate holder observations are errors. Never demand another device's private keys on the current machine. Missing-key checks apply to current-device expected private material recorded as present or unknown; archived/removed material is not expected at its old path.

### Authorization fields

Each destination requires all these fields:

- `kind`: enum `server`, `account`, or `deploy_key`.
- `host`: nonempty destination hostname, not shell syntax, SSH URL, or a command.
- `account`: nonempty string or null; server login or service account identity, not necessarily SSH transport user `git`.
- `repository`: nonempty string or null; deploy-key repository scope.
- `ssh_alias`: nonempty string or null; optional client alias, not a remote command.
- `verification_status`: enum `unverified` or `verified`.
- `verified_at`: ISO UTC timestamp or null.
- `revocation_status`: enum `not_started`, `pending`, or `completed`.
- `revoked_at`: ISO UTC timestamp or null.
- `evidence`: optional descriptive string or null; required nonempty for completed revocation. Never embed credentials or full sensitive command output.

An unverified destination may have unknown account/repository scope. Verified destinations require account and verification timestamp; verified deploy keys also require repository. Non-deploy destinations use null repository. Unverified destinations use null verification timestamp. Completed revocation requires completion timestamp and evidence; other revocation states use null completion timestamp. Reject duplicate `(kind, host, account, repository)` destination tuples within a key. Client aliases do not create distinct authorization locations.

## Lifecycle and audit interpretation

- Rename: change holder path only; fingerprint and remote authorization remain unchanged.
- Routine rotation: add new fingerprint at a distinct path, link `replaces`, verify isolated replacement identity, then revoke old destinations individually.
- Retiring: unresolved revocation stays visible even when local material is archived or removed.
- Retired: require complete authorization scope and every recorded destination revoked. Empty destination list does not establish complete scope by itself.
- Archived storage: `$SSH_DIR/retired/` is excluded from default key-file inspection, not registry lifecycle checks. No automatic archival or deletion.
- Missing private/public matching evidence is explicitly uncheckable, not a claim of security. Empty-passphrase failure does not prove encryption or protection.

Registry is metadata, not authorization enforcement or proof of effective access. Audit warnings never authorize mutation. Unknown age, incomplete scope, and unused-looking filenames are investigation items, not deletion instructions.

## Repository integration and safety

`~/.bin` currently symlinks to `.dotfiles/.bin`, and Home Manager adds it to PATH. Source `common` relative to the script directory; test both direct and symlink-directory invocation. Do not assume `readlink -f` exists on macOS.

Shared helpers provide Bash safe mode and stderr warning/error logging, but `log_info` writes stdout and `die` exits 1. Audit must adapt these behaviors: reserve stdout for JSON when requested, return contract error code 2, and avoid error traps that disclose sensitive command arguments. Do not change shared helpers globally for this feature.

Use Bash 3.2-compatible constructs or explicitly fail unsupported versions; Phase 2 targets Bash 3.2 and current Bash. Bash, OpenSSH, jq, and Mike Farah yq v4 are locally available; jq and yq-go are already declared in `home/core.nix`. ShellCheck is not currently on PATH; record this coverage gap if unavailable during tests.

Phase 5 registry source from `.config/nix/home/ssh-aliases.nix` is `../../ssh/keys.yaml`. Deploy via `xdg.configFile` only after baseline population and separate activation approval. Existing Home Manager configuration uses `backupFileExtension = "backup"`; review collisions rather than assume unmanaged files can be overwritten. Refer to private-key paths only; never import key contents into Nix.

Approved registry content is restricted to public fingerprints, device labels, and the minimal host/account/repository metadata needed for lifecycle management. Existing repository already contains internal host labels; this is not proof of repository privacy. Exclude sensitive notes and secret-store identifiers by default; backup references remain null unless separately approved. Review actual registry diff before committing or sharing. Do not contact hosting services to determine visibility during local preflight.
