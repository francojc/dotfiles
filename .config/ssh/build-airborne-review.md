# Airborne build review – Phase 6, Step 3

Current status: Forgejo-only migration complete after owner-confirmed activation, isolated account/repository-read tests, final metadata, and approved two-link cleanup. Step 3 and subsequent gate sections below preserve historical evidence; latest completion section supersedes their pending states. Other pairs, write access, and complete authorization scope remain unresolved. Compatibility links removed after those gates passed; older rollback requires collision-safe recreation before activation.

## Registry safety correction

Airborne `~/.config` is a symlink to `~/.dotfiles/.config`; runtime registry and canonical tracked registry are the same file. Integrated Home Manager backup policy moves regular targets before its identical-content skip. The previous enabled registry entry would back up and replace the canonical repository file during activation, despite `force = false`.

Approved correction: `xdg.configFile."ssh/keys.yaml".enable = hostname != "Macbook-Airborne"`. Airborne reads the existing repository-managed file at the default runtime path. Other hosts retain staged registry entries, with filesystem-topology review required before their activation. No backup policy, private-key paths, or other device readiness changed by this correction. Keep this safety correction even if rolling back Forgejo naming.

## Build and outputs

Executed from `.config/nix`:

```bash
nix build --no-link --json '.#darwinConfigurations.Macbook-Airborne.system'
```

- Built Darwin system: `/nix/store/k3xp86d239xszzjzgfvry72anmk4yik6-darwin-system-26.11.15abb8c`.
- Built Home Manager generation: `/nix/store/4nk63ra9p1a11fkna9mha5lp4x6arzjg-home-manager-generation`.
- Built home-files: `/nix/store/xyhyjnd2l5v8nrg4vgpfpdlw2bcfvfw8-home-manager-files`.
- Current/rollback Darwin system: `/nix/store/lhxxddpahl2bris6yb9m5pskrxpx89r0-darwin-system-26.11.15abb8c`.
- Current Home Manager generation: `/nix/store/llhqq4c9fls34h7mm7acmzdn6nfha1hf-home-manager-generation`.

No result symlink, sudo, profile change, switch, or activation. Build fetched one small builder dependency from Nix binary cache; no SSH remote access or authentication. Build used uncommitted tracked correction; no Git staging/commit performed. Recheck built output existence before activation because `--no-link` creates no persistent result GC root.

## Inspection results

- Five isolated wiring groups pass, including Airborne-only registry management exclusion and exact SSH directives.
- Full Home Manager option evaluations pass for all four supported hosts. Airborne has no enabled registry target; others retain theirs.
- Actual built home-files contain no `.config/ssh/keys.yaml`. Current generation also has no such file, so Home Manager removal cleanup does not target the existing canonical registry.
- Built `nix-managed.conf` differs from current generation only in Forgejo IdentityFile: `~/.ssh/id_ed25519_airborne_forgejo`.
- Session variables add only `SSH_KEY_AUDIT_DEVICE="airborne"`.
- `.zprofile` and `.zshenv` differ only in generated session-vars store reference.
- Applications link-set contents unchanged; generated link target changes. Font marker changes generated store reference; old/new font file trees empty and unchanged.
- System `etc` change limited to generated per-user profile reference. No system-user tree changes found.
- `nix store diff-closures` reports no package-version/size changes.
- Bash 3.2 syntax and `git diff --check` pass.
- Current `/run/current-system` unchanged after build.

Build warnings: expected pending Codeberg/workstation readiness; upstream `options.json` derivation store-context warning. Neither prevented build. Native Linux activation, real remote authentication, and live Home Manager execution remain untested.

## Next gate and rollback

Stop before Step 4. Activation requires separate approval of exact command and built configuration. Recheck canonical registry remains unmanaged, output availability, effective config, current generation, and compatibility links immediately before activation.

Retain both old-path compatibility links. At Step 3, existing current/rollback configuration references those paths, so reverting activation remains usable without moving key material. Review exact rollback activation command and profile generation before proceeding; do not invoke activation scripts or rollback now. Renaming rollback additionally requires private manifest, exact-link/inode checks, no-overwrite moves, and scoped registry/readiness changes; never revert unrelated edits or registry safety correction.

## Step 4 – External activation observed, local verification passed

Read-only follow-up found system profile generation 674 and `/run/current-system` pointing to reviewed build. Agent did not execute activation; owner confirmation of external activation is requested. Live managed SSH file exactly matches built output. Alias and FQDN effective configs select only renamed Forgejo identity, with unchanged destination/user/port/host-key alias. Deployed session-vars file exports `SSH_KEY_AUDIT_DEVICE="airborne"`. These checks verify selected local cutover, not every system activation hook.

Canonical registry contents/topology unchanged; no registry backup created. Both compatibility links/inodes and 600/644 pair modes unchanged. Default-path audit completes with zero errors, 18 warnings. Private manifest remains unchanged and retains historical pending/not-approved state; owner confirmation required before reconciling it. Integrated Home Manager activation uses driver version 1 and does not update standalone user profile, so older standalone profile does not imply integrated activation failure.

Generation 673 remains available. Inspected installed darwin-rebuild source confirms exact rollback command below switches system profile to specified generation and activates it. Not executed or approved; recheck generation identity before any rollback:

```bash
sudo /run/current-system/sw/bin/darwin-rebuild --switch-generation 673
```

### Proposed remote gate – Authentication only

No remote command executed. Proposed command isolates renamed identity from user/system SSH configuration, agent fallback, certificates, and multiplexed sessions; requires existing host trust and disables host-key updates. Verbose authentication trace permits checking accepted client fingerprint. Client fingerprint must be `SHA256:2uikUsy/rGyU1EWnDqFWHGKlZ6UoVzy5tOXwqQutUeI`.

Existing local trust for alias `forgejo` is Ed25519 server fingerprint `SHA256:PO3GPEYGmLBd7y6W1h+LM/U3i5Dge0qSzojF56zHvDc`; do not confuse server and client fingerprints. Unknown/changed host key must fail, not prompt for enrollment.

```bash
ssh -v -F /dev/null -T -p 22 \
  -i "$HOME/.ssh/id_ed25519_airborne_forgejo" \
  -o IdentityAgent=none -o IdentitiesOnly=yes -o CertificateFile=none \
  -o BatchMode=yes -o PreferredAuthentications=publickey \
  -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no \
  -o StrictHostKeyChecking=yes -o UpdateHostKeys=no \
  -o UserKnownHostsFile="$HOME/.ssh/known_hosts" \
  -o GlobalKnownHostsFile=/dev/null -o HostKeyAlias=forgejo \
  -o ControlMaster=no -o ControlPath=none -o ControlPersist=no \
  -o ForwardAgent=no -o ClearAllForwardings=yes \
  -o ConnectTimeout=10 -o ConnectionAttempts=1 \
  forgejo@forgejo.gerbil-matrix.ts.net
```

Authentication may return a nonzero exit code because Git service disallows interactive shells; evaluate accepted key and account greeting rather than exit code alone. Owner must confirm returned account is intended. Greeting alone does not prove required repository access. Dotfiles origin points to GitHub; no Forgejo repository scope established from it. Request intended Forgejo account and repository URL, then review a separately approved isolated read-only repository test before marking scope verified. No remote authorization changes, agent loading, compatibility cleanup, or Phase 7 implied.

## Step 5 – Approved authentication passed (2026-10-05)

Owner confirmed external build/switch, approved authentication command above, and specified expected Forgejo account `jeridf`. Supplied `https://forgejo.gerbil-matrix.ts.net/` identifies instance; required repository scope remains unknown.

Executed reviewed command once. Exit 0. Strict existing host trust matched recorded server fingerprint. Trace shows selected explicit client fingerprint offered and accepted, followed by successful publickey authentication; no other identity offered.

Forgejo response:

```text
Hi there, jeridf! You've successfully authenticated with the key named Airborne, but Forgejo does not provide shell access.
```

Account matches owner expectation. Remote key label `Airborne` is cosmetic and unchanged. No agent fallback, certificate, multiplex reuse, host-trust updates, remote authorization edits, or key/link changes.

Authentication proof does not establish access to any particular repository or write permission. Next: obtain specific repository URL, review exact isolated read-only `git ls-remote` test, and obtain approval. Keep both compatibility links. Registry and private manifest retain historical pending fields until final migration metadata reconciliation; use this follow-up as current account-authentication evidence. Phase 6 remains incomplete.

## Selected repository read passed (2026-10-05)

Owner requested test of `ssh://forgejo@forgejo.gerbil-matrix.ts.net/jeridf/narratr.git`. Executed read-only command below with same identity, trust, agent, certificate, and multiplex isolation as authentication test. Global/system Git config disabled and command run outside local repository to avoid URL rewrites/local config effects.

```bash
GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_TERMINAL_PROMPT=0 GIT_SSH_VARIANT=ssh \
GIT_SSH_COMMAND='ssh -v -F /dev/null -T -p 22 -i /Users/francojc/.ssh/id_ed25519_airborne_forgejo -o IdentityAgent=none -o IdentitiesOnly=yes -o CertificateFile=none -o BatchMode=yes -o PreferredAuthentications=publickey -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no -o StrictHostKeyChecking=yes -o UpdateHostKeys=no -o UserKnownHostsFile=/Users/francojc/.ssh/known_hosts -o GlobalKnownHostsFile=/dev/null -o HostKeyAlias=forgejo -o ControlMaster=no -o ControlPath=none -o ControlPersist=no -o ForwardAgent=no -o ClearAllForwardings=yes -o ConnectTimeout=10 -o ConnectionAttempts=1' \
git -C / ls-remote -- 'ssh://forgejo@forgejo.gerbil-matrix.ts.net/jeridf/narratr.git'
```

Exit 0. Trace confirms only selected client key offered/accepted, trusted server fingerprint matched, and `git-upload-pack '/jeridf/narratr.git'` executed. Returned:

```text
94793afcd8f0e678f422727c6d1c98253f6c06d9 HEAD
94793afcd8f0e678f422727c6d1c98253f6c06d9 refs/heads/main
```

Evidence proves selected repository ref advertisement/read access. No clone, fetch, push, remote authorization edit, agent change, host-trust update, or local repository mutation. Write access and complete authorization scope remain unproven.

Next: obtain separate approval for removal of only two recorded old-path compatibility symlinks and final registry/private-manifest metadata reconciliation. Renamed private/public key files remain untouched. Older rollback generation 673 references old identity path; after link cleanup, restore exact recorded links before activating it, or approve coordinated full rename rollback. Do not claim rollback configuration remains usable without this prerequisite. Phase 6 remains incomplete until cleanup/checkpoint; no other pair or Phase 7 work implied.

## Final checkpoint – Forgejo-only migration complete (2026-10-05)

Owner approved removal of both exact recorded compatibility symlinks and final registry/private-manifest updates. Preflight reconfirmed active generation 674, exact live SSH configuration, alias/FQDN renamed identity selection, public fingerprint, file identities/ownership/modes, exact links, and canonical registry topology. Removed only old-path private/public symlinks at `2026-10-05T03:03:17Z`. Renamed files retain original inodes and 600/644 modes; no key material copied or changed.

Registry records verified `jeridf` account and selected narratr read evidence. Account-kind repository stays null; authorization_scope_complete remains false. Write access not tested. Other registry records/devices unchanged. Airborne runtime canonical registry remains regular and repository-managed, with Home Manager deployment disabled.

Private manifest finalized outside Git, retaining historical move/link/checkpoint evidence plus final hashes, verification, cleanup, and rollback fields. Modes remain 700 directory/600 file. Before activating older rollback generation 673, recreate exact removed relative compatibility links with no-overwrite checks after validating renamed files; otherwise old configuration cannot locate identity. Preserve registry topology correction and verified authorization evidence. No rollback executed.

Final local audit: zero errors, 18 warnings, unchanged inventory fingerprints. Report `migration-airborne-forgejo-complete.json`; prior rename report preserved. Five wiring groups, full Home Manager evaluations for all four supported hosts, 15 Bash 3.2 audit groups, and git diff --check pass. Final manifest/hashes/modes/cleanup and rollback generation independently verified. Active paths remain valid after cleanup. No extra rebuild/activation/remote operation during cleanup, no agent/trust/authorization changes, no other pair touched, no Git staging/commit.

Stop point: approved Forgejo-only migration complete. Next separately choose review/commit, Phase 7 mocked remote-drift implementation, Phase 8 documentation, or another scoped inventory/migration. Remaining security/protection findings need owner policy, not automatic remediation. Detailed next-step list in `plans/ssh-key-management.md`.

## Checkpoint repository review (2026-10-05)

Owner approved review and commit only, stopping before Phase 7. Reviewed eight-file scope: Airborne registry exclusion, three wiring-test files, registry metadata, registry README, this historical build/cutover review, and sanitized completed audit report. Removed stale current-status wording about retained links and uncommitted checkpoint. Historical gate sections remain dated evidence, not current instructions.

Fresh checks: five wiring groups and 15 Bash 3.2 audit groups pass; git diff --check passes. Changes retain account/read versus write/scope distinction, collision-safe rollback prerequisite, and other-device deployment gates. No private material included. Private rollback manifest remains outside Git; local plan remains ignored. Commit step introduces no activation, live remote tests, agent changes, or key operations. Stop before Phase 7.
