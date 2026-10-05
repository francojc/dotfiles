# SSH keys – What to do and what to look for

Use this guide for routine review and planning. Commands labeled **local check** inspect local state; they do not authorize repairs. Workflows labeled **approval required** change access or key material and must be reviewed separately. Never paste private keys, passphrases, or tokens into Git, chat, logs, or a Nix expression.

## 1. Start here

On Airborne, run this **local check**:

```bash
ssh-key-audit --device airborne
```

What it does: reads registry and local SSH files, checks public fingerprints and checkable software pairs, observes empty-passphrase usability non-interactively, and reports naming, permissions, and lifecycle findings. It uses temporary scratch files but does not change keys, registry, permissions, agents, host trust, or remote systems. Derived public output is discarded; hardware touch/PIN is not requested.

What to look for:

| Result | What it means | What to do |
|---|---|---|
| Zero errors, existing warnings | Report completed; warnings still need review | Compare with known findings below; choose one investigation |
| New fingerprint or unregistered key | Registry does not describe observed identity | Identify owner/use before adding metadata; do not delete |
| Pair mismatch, invalid key, malformed registry | Verification failed | Stop migration; investigate with original files intact |
| Missing key | Current device expects material at recorded path | Check path, deployment, and holder record; never copy another device's private key as a quick fix |
| Empty-passphrase warning | Software private key can be used without unlocking | Decide protection policy; no automatic passphrase change or rotation |
| Unsafe permissions/ACL finding | Storage may expose access | Review parent directories, ownership, and ACLs before approving a scoped repair |
| Unknown scope/date or uncheckable key | Evidence is incomplete | Keep unknowns explicit; do not infer safety, expiry, or disuse |
| Retiring key with pending revocation | Old access may still exist | Review each destination; local deletion is not revocation |

For structured output or warning-sensitive automation:

```bash
ssh-key-audit --device airborne --json
ssh-key-audit --device airborne --strict
```

Exit codes: **0** completed without errors (warnings allowed), **1** warnings under `--strict`, **2** invalid input, registry/key validation error, missing dependency, or failed required operation. JSON can also describe a failed preflight; check `completed` and exit code, not just whether JSON parsed. JSON diagnostics go to stderr; do not mix stderr into a JSON parser.

## 2. Know the current checkpoint

Snapshot from 2026-10-05, not a promise that future local state is unchanged:

| Device or pair | State | What to look for next |
|---|---|---|
| Airborne Forgejo | Migration complete; renamed pair active; account `jeridf` and `jeridf/narratr.git` read verified | Preserve fingerprint and current path; write access/full authorization scope remain unverified |
| Airborne Codeberg/workstation | Legacy paths retained; not migrated | Confirm pair, references, account/destinations, and recovery access before selecting either |
| Airborne VM/PAOS/default | Usage unresolved | Establish actual consumers and authorizations; default keys can be selected without explicit references |
| Airborne Omarchy | Unregistered pair, protection/matching uncheckable in current audit | Investigate provenance/use; failure of empty-passphrase check is not proof of encryption |
| Minicore/Rover/Quattro | Unprovisioned inventory records; existing legacy config retained | Public-only inventory and runtime topology review on each device |
| Optional remote-drift checker | Skipped by owner decision | `ssh-key-audit --check-remote` remains unsupported, exit 2 |

Airborne Forgejo private/public paths are `~/.ssh/id_ed25519_airborne_forgejo` and the same name plus `.pub`. Client fingerprint: `SHA256:2uikUsy/rGyU1EWnDqFWHGKlZ6UoVzy5tOXwqQutUeI`. Old-path compatibility symlinks have been removed. Private/public modes were 600/644; original file identities remained unchanged.

Final recorded audit: **0 errors, 18 warnings** – eight naming findings, six empty-passphrase findings, two unregistered Omarchy findings, and two directory-mode findings. Counts include private/public naming findings, not 18 distinct keys. Parent SSH directory was restrictive; directory warnings alone do not prove external exposure. Reports: [completed migration audit](migration-airborne-forgejo-complete.json), [build and cutover evidence](build-airborne-review.md), and [original baseline](baseline-airborne.md).

## 3. Check identity, not labels

For the selected Forgejo public key, this **local check** prints its fingerprint:

```bash
ssh-keygen -E sha256 -lf "$HOME/.ssh/id_ed25519_airborne_forgejo.pub"
```

Compare with registry and migration evidence. A filename, comment, or Forgejo key label is not identity. Renaming does not change fingerprint or remote access. Never print the private file to inspect it.

For current reviewed Airborne config, these **local checks** show selected identities without connecting:

```bash
ssh -G forgejo
ssh -G forgejo.gerbil-matrix.ts.net
```

Look for exactly the renamed `identityfile`, intended user `forgejo`, destination, port 22, `identitiesonly yes`, and host-key alias `forgejo`. Account identity `jeridf` differs from SSH transport user `forgejo`. Effective config is selection evidence, not authentication evidence. Review unfamiliar configs before `ssh -G`: `Match exec` can execute local commands even during configuration evaluation.

Client fingerprint identifies your key. Server fingerprint identifies trusted destination. Do not confuse them. Never accept a changed server key just to make a test pass.

## 4. Audit setup and limits

Dependencies: Bash 3.2+, OpenSSH `ssh-keygen`, `jq`, **Mike Farah yq v4** (`yq-go` in Nix), and standard shell/file utilities. `~/.bin` exposes repository scripts through existing symlink/PATH wiring. See `ssh-key-audit --help`; audit does not support every shared script flag such as dry-run or quiet.

| Selection | Precedence |
|---|---|
| Registry | `--registry PATH` → nonempty `SSH_KEYS_REGISTRY` → `${XDG_CONFIG_HOME:-$HOME/.config}/ssh/keys.yaml` |
| SSH directory | `--ssh-dir PATH` → nonempty `SSH_DIR` → `$HOME/.ssh` |
| Device | `--device NICKNAME` → nonempty `SSH_KEY_AUDIT_DEVICE` → normalized hostname match |

Unknown explicit device is an error. Unknown automatically detected hostname is informational and skips current-device missing-key checks; that is not a complete device audit. There is no fallback to an undeployed repository registry.

Airborne runtime registry already is canonical repository file through `~/.config` symlink. **Keep Home Manager registry management disabled there.** Its backup/link behavior can move the canonical file even with `force = false`. Other hosts need their own filesystem review before registry activation.

Limits to look for:

- All symlinks are excluded from key-file inventory; verify any required targets separately. Config Include/IdentityFile references are detected, not expanded or executed by audit.
- OrbStack/external tool identities and `retired/` key files are out of default scan. Archived keys still receive registry lifecycle checks.
- Native Linux, physical tokens, and real extended-ACL cases remain coverage gaps; fixture mocks are not proof of deployed behavior. Unavailable ACL/ownership inspection must remain a gap.
- Audit does not inspect effective remote authorization, certificates, `AuthorizedKeysCommand`, or hosting-service account/deploy-key settings. No network runs by default; optional checker was skipped.
- File timestamps do not prove creation date. Age reminders are not automatic expiry. A failed empty-passphrase check means encrypted **or uncheckable**, not automatically secure.

`ssh-key-audit --init` emits starter YAML only; it neither deploys nor edits registry. Review output separately before any merge; keep unknown authorizations/dates unknown. Do not redirect it onto canonical registry. `--init` and `--json` cannot be combined.

## 5. Onboard a device – approval required

| Device | Nix identity | Configured user |
|---|---|---|
| Minicore | `Mac-Minicore` | `jeridf` |
| Rover | `Mini-Rover` | `jeridf` |
| Quattro | `nixos-quattro` | `jeridf` |

For an existing device:

1. Agree on device, access method, and public-only inventory commands. Confirm actual hostname/user; configured identity alone does not prove deployment.
2. Inventory on that device. Compare public fingerprints, actual relative holder paths, protection observations, and references. Never collect/copy private keys to Airborne. A shared software fingerprint is a reuse investigation, not automatic permission to revoke it.
3. Add confirmed public metadata to `keys.yaml`; one fingerprint gets one record, with additional holder observations if genuinely shared. Set device `provisioning: inventoried` only after inventory. Keep unresolved use/scope explicit.
4. Review runtime registry path and symlink topology. Leave service readiness false until selected pair exists and cutover is approved. Inventory state alone must not activate intended paths.
5. Evaluate host config, review collision/backup behavior and recovery access, and separately approve deployment. No activation may reference a missing key.
6. Audit locally with explicit nickname, then separately approve isolated account/repository checks. Do not treat other devices' missing keys as local defects.

For a new device, add an explicit nickname/hostname mapping in `.config/nix/home/ssh-key-paths.nix` and registry, evaluate unsupported-host behavior, then generate independent keys only when approved. Do not inherit Airborne key files. Desired naming is `id_ed25519_<holder-nickname>_<purpose>`; holder device is not destination server.

## 6. Rename versus rotate – choose deliberately

**Rename** when organizing an existing working pair: preserve fingerprint and passphrase, review all references, refuse collisions, record private rollback manifest outside Git, approve temporary links or coordinated cutover, separately approve activation and isolated checks, then separately approve link cleanup. Do not alter remote authorizations merely because filename changed.

**Rotate** when evidence warrants it: suspected compromise, unwanted software-key sharing, or failure of agreed protection policy. Unknown age alone is not a rotation reason. Suspected compromise needs an incident-specific containment decision; routine overlap must not delay urgent revocation.

Routine rotation checklist – each live step needs approval:

1. Identify old fingerprint and every intended destination. Confirm working emergency access independent of old/replacement key, such as tested console or separately held admin identity.
2. Choose a distinct replacement path. Preview only:

   ```bash
   ssh-key-setup -n --replacement-name id_ed25519_airborne_forgejo_review1 airborne forgejo
   ```

   Dry-run performs validation/collision checks without generation, writes, or registry output. `--force` cannot override collisions.
3. Separately approve actual generation and protection policy. Generator prompts for passphrase; never supply one in shell arguments/history. Failed publication can leave partial **new** output for inspection; do not rerun blindly or delete existing material.
4. Review emitted JSON suggestion and merge only confirmed metadata. Create a new fingerprint record, link `replaces` to old fingerprint, and keep authorization scope incomplete until verified. Generator never edits registry itself.
5. Register replacement public key alongside old key, preserving others' access. Verify replacement separately for each required account/repository/destination.
6. Stage and approve cutover, verify active selection and intended operations, then approve old authorization removal destination by destination. Keep old record `retiring` while any revocation or scope gap remains.
7. Mark `retired` only after all known destinations are revoked and scope complete. Local archival/deletion, agent unloading, and compatibility-link removal require separate exact-path approval; none revoke remote access.

`ssh-key-setup --check-remote` is a separate generator smoke-test opt-in, not the skipped audit drift checker and not sufficient lifecycle verification. Its acceptance message does not establish expected account/repository or complete scope. Do not use it as sole evidence before revocation.

## 7. Verify a replacement without fallback – approval required

Prepare a private, reviewed client config outside Git. This is a **template**, not permission to connect. Replace all placeholders; preserve destination user, port, existing trusted host-key alias, and any required routing. Review jump-host authentication separately rather than dropping routing options to force this direct template to work.

```sshconfig
Host replacement-review
  HostName DESTINATION_HOST
  User TRANSPORT_USER
  Port 22
  IdentityFile ~/.ssh/REPLACEMENT_KEY_NAME
  IdentitiesOnly yes
  IdentityAgent none
  CertificateFile none
  PreferredAuthentications publickey
  PasswordAuthentication no
  KbdInteractiveAuthentication no
  BatchMode no
  StrictHostKeyChecking yes
  UpdateHostKeys no
  UserKnownHostsFile ~/.ssh/known_hosts
  GlobalKnownHostsFile /dev/null
  HostKeyAlias EXISTING_TRUSTED_ALIAS
  ControlMaster no
  ControlPath none
  ControlPersist no
  ForwardAgent no
  ClearAllForwardings yes
  ConnectTimeout 10
  ConnectionAttempts 1
```

`BatchMode no` permits a local private-key passphrase prompt; password/interactive server authentication remains disabled. No agent fallback is allowed. For noninteractive testing, `BatchMode yes` will fail on a locked encrypted key unless a separately reviewed unlocking/authentication method is provided; do not remove passphrase protection just to pass a test.

After reviewing config/includes and storing template at `~/.ssh/replacement-review.conf`, inspect selection first:

```bash
ssh -G -F "$HOME/.ssh/replacement-review.conf" replacement-review
```

Only after approval of exact destination/config/command, run an isolated authentication test such as:

```bash
ssh -v -F "$HOME/.ssh/replacement-review.conf" -T replacement-review
```

Look for **selected replacement fingerprint accepted**, authentication success, expected service account, and unchanged trusted server identity. An ordinary successful SSH command can use another configured key, agent, certificate, or multiplex session. Git services may exit nonzero because shell access is disabled; verify fingerprint and greeting, not exit code alone.

Then review a separately approved repository operation using the same isolated SSH config and preventing Git URL/config rewrites, following [recorded Forgejo read-test pattern](build-airborne-review.md). `git ls-remote` verifies advertised refs/read access, not write permission or every repository scope. If write access matters, agree on a specific safe verification method rather than an unsolicited push. Never automatically mark all destinations verified after one test.

## 8. Revoke and clean up safely – approval required

For each old authorization, record host, account/repository, exact fingerprint, intended action, remaining access, and evidence. Remove only selected public-key entry from hosting settings, deploy-key configuration, or server authorization source. Preserve authorized-key options, emergency access, and other users. A conventional `authorized_keys` file may not be authoritative when certificates/custom paths/commands apply.

Update each destination's revocation status/date/evidence only after confirmed removal. Keep `authorization_scope_complete: false` until owner confirms coverage. Removing local private file or agent entry is **not** revocation. Preserve fingerprint and retired history; never erase evidence to silence warnings.

For unknown keys, dates, or directories: investigate consumers and scope first. Avoid blanket chmod, cleanup globs, automatic rotation, and secret-store lookups. Backups remain unknown/null until protection, storage, recovery, and metadata privacy policy are separately approved.

## 9. Roll back Airborne Forgejo – approval required

Current approved migration removed old-path links; generation 673 still expects old path. **Do not activate generation 673 before restoring usable old paths.** A Git revert does not rename local files or switch active config.

1. Inspect private manifest at `~/.ssh-key-migration-forgejo-71_0kg91/manifest.json`; keep it outside Git. Confirm recorded fingerprint, file identities/modes, exact relative link targets, current edits, and generation identity/availability. Numbers may be reused or generations removed; recheck, do not assume.
2. Require both old paths absent, including dangling symlinks. Separately approve recreating only `id_ed25519_forgejo` → `id_ed25519_airborne_forgejo` and `.pub` → `id_ed25519_airborne_forgejo.pub`, with exclusive/no-overwrite creation. Stop on any collision; never use force-link replacement.
3. Confirm both restored links resolve to recorded renamed files. Review exact rollback activation and independently verify recovery access.
4. Only after approval and prerequisites, recorded rollback command is:

   ```bash
   sudo /run/current-system/sw/bin/darwin-rebuild --switch-generation 673
   ```

5. Inspect effective config and audit; connection tests require their own reviewed approval. Full rename reversal additionally needs coordinated non-overwriting file moves and scoped holder/readiness edits. Preserve registry safety exclusion and valid account-verification evidence. Never blanket-reset unrelated Git changes.

No rollback is performed by this guide. Renamed keys may stay in place with restored compatibility links for config rollback; full filename rollback is a distinct operation.

## 10. Pick one next action

- **Finish repository work:** review Phase 7 skip changes and Phase 8 guide/docs/tests, then approve commit. Do not stage ignored plan or private manifest by default.
- **Investigate protection:** choose one finding and define policy before any permission/passphrase/rotation operation.
- **Migrate another pair:** select Codeberg or workstation only after fresh pair/reference/recovery review; use new operational approvals.
- **Inventory another device:** agree on device/access/public-only scope; confirm topology before deployment.

## Documentation verification

Run isolated suites from repository root, not against live keys:

```bash
BASH_UNDER_TEST=/bin/bash bash .bin/tests/ssh-key-audit/run.sh
BASH_UNDER_TEST=/bin/bash bash .bin/tests/ssh-key-setup/run.sh
bash .config/nix/tests/ssh-key-wiring/run.sh
```

Phase 8 verification (2026-10-05): **15 audit groups and 11 generator groups passed under both Bash 3.2.57 and Bash 5.3.15; five wiring groups passed**. Both-interpreter syntax checks, local Markdown links/anchors, code-fence checks, rollback-prerequisite check, and `git diff --check` passed. ShellCheck unavailable.

Documentation diff adds this guide and updates `.bin/README.md` plus `.config/ssh/README.md`. Earlier uncommitted Phase 7 skip changes also adjust audit help/error wording and its rejection test; no remote checker exists. All changes await review/commit. Private manifest remains outside Git; plan remains ignored.

Audit and generator fixtures use temporary HOME/SSH directories; remote/agent/UI effects are mocked or forbidden. Wiring tests evaluate local Nix expressions only; they do not activate config or connect to SSH. Test results validate implemented behavior, not native Linux deployment, physical tokens, real ACL exposure, emergency-access availability, or remote authorization coverage.

For full field rules, see [registry contract](README.md). For CLI/generator overview and fixture-test commands, see [script README](../../.bin/README.md#ssh--ssh-key-management). Phase 9 server-side declarations, encrypted backups, and certificates remain optional, separately approved work.
