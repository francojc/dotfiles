# Airborne SSH baseline – Phase 3

Observed: 2026-10-04 UTC. Status: local baseline complete; registry draft awaits owner review. No migration, deployment, remote access, or commits performed.

## Artifacts and scope

- `keys.yaml`: six distinct public fingerprints, actual Airborne paths, desired labels, and five unverified destination records across four keys.
- `baseline-airborne.json`: sanitized machine-readable before-migration audit; no private bytes, public-key comments, or secret-store references.
- Local hostname `Macbook-Airborne` normalizes to `macbook-airborne`. Minicore, Rover, and Quattro remain unprovisioned; their aliases are configuration-backed, not runtime-verified.
- Audit scanned owned client keys locally. Inbound authorization, host-trust files, certificates, and archived material are not client-key inventory. OrbStack's included configuration and identities remain outside reviewed scope.
- Read `~/.ssh/config` and explicitly inspected the Home Manager-generated `config.d/nix-managed.conf` symlink target as text. Its key references agree with repository `home/ssh-aliases.nix`. No automatic Include expansion, `ssh -G`, proxy command, or connection executed.

## Results

Normal audit exit `0`: completed, zero errors, 18 warnings. All six public fingerprints independently recomputed from `.pub` files; all are Ed25519, distinct, and match their private companions. All six software keys are usable with an empty passphrase. This is a protection finding, not evidence of compromise or authorization to rotate.

| Finding | Count | Interpretation |
|---|---|---|
| Empty-passphrase software keys | 6 | Protection policy needs owner decision; no automatic passphrase change or rotation |
| Naming notices | 10 | Five desired renames, reported once for private file and once for public companion |
| Directory-mode warnings | 2 | `paos/` and `config.d/` are owner-held mode `755`; no repair performed |
| Metadata unknown | 6 | Creation dates and complete authorization scope remain unknown |
| Include coverage gap | 1 | OrbStack identities not inventoried; includes not executed |
| Excluded symlink | 1 | Managed config separately inspected as text, not followed by CLI |

`~/.ssh` is owner-held mode `700`; all six private files are owner-held mode `600`. Native macOS ACL inspection reported no extended ACL findings on inspected directories/private files. Child-directory `755` modes alone do not establish access by other users through the mode-`700` parent. Audit flags them conservatively; no demonstrated private-key exposure from these mode findings. Native Linux and real extended ACL exposure remain untested.

## Per-key recommendations

| Actual private path | Desired label | Recommendation and evidence |
|---|---|---|
| `id_ed25519_codeberg` | `id_ed25519_airborne_codeberg` | Retain; rename candidate. Matching pair; managed client reference to Codeberg. Service account unknown; transport user `git` is not account identity. |
| `id_ed25519_forgejo` | `id_ed25519_airborne_forgejo` | Retain; rename candidate. Matching pair; managed Forgejo reference. Service account unknown; transport user `forgejo` is not account identity. |
| `id_ed25519_workstation` | `id_ed25519_airborne_workstations` | Retain; rename candidate. Matching pair; managed references to Minicore and Airborne. Login names inferred from config, not authorization verified. |
| `nixos-machine` | `id_ed25519_airborne_nixos` | Investigate VM use before rename. Matching pair; local `nixos.machine` reference exists. |
| `paos_ed25519` | `id_ed25519_airborne_paos` | Investigate tooling and destinations; purpose remains `unknown`, desired label provisional. Matching pair; filename alone proves no usage. Preserve `paos/known_hosts`. |
| `id_ed25519` | Unchanged | Retain; investigate implicit default selection and destinations. Matching pair; no explicit reference does not establish disuse. |

No selective rotation selected: no compromise or cross-device private-key reuse established. Protection requirements remain unresolved; owner review may trigger a separately scoped remediation or rotation decision. Unknown age alone is not a rotation trigger.

## Registry review and limits

All keys remain `active` as conservative inventory state, not proof of current use or effective access. `created`, `backup`, and `review_after_months` remain null; no age interval policy invented. Authorization scope is incomplete for every key. Five destinations are configuration-inferred and `unverified`; no repository/deploy-key scope, remote account identity for Git services, or remote authorization invented. Passphrase observations live in this report, not unsupported registry fields.

Registry and report contain public fingerprints, local filenames/device labels, and minimal client-derived destination metadata already present in configuration. No private bytes, credentials, public-key comments, sensitive backup references, or secret retrieval commands included. Owner must review actual new-file diff before committing or sharing; repository visibility remains unverified. Neither registry nor report deployed.

Cross-device comparison deferred pending separate public-only inventory approval. Symlinks remain conservatively excluded by CLI; tool-managed and archived material remain scope gaps, not claims of absence. No physical token observed; physical-token and native Linux behavior remain unverified. ShellCheck unavailable.

## Next stop

Stop after Phase 3. Next implementation phase: Phase 4 safe generator prerequisites, repository code and isolated fixtures only. Protection changes, permission repairs, other-device inventory, live generation, rename, agent operations, activation, and remote verification still require separate approval.
