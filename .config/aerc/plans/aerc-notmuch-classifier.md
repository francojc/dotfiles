# Plan: basic aerc + notmuch + Ollama pilot

## Context

Test local search and semantic tagging by switching existing `[Work]` account to notmuch on current non-main branch. Pilot host: **Macbook-Airborne**, confirmed by user. Mailbox account remains unchanged; Gmail sync remains pull-only.

Installed aerc 0.22 already supports notmuch. Pinned Nixpkgs supplies isync 1.5.1 and notmuch 0.40; its Ollama 0.32.5 is too old for decision API. Homebrew currently supplies compatible Ollama 0.35.1. Existing Python, pass, jq, and aerc declarations suffice for remaining dependencies.

## Approach

Pull-only Gmail → local Maildir → notmuch → existing `[Work]` account. Manually run a small Python classifier against local Ollama; validate structured judgments and apply only allowlisted local tags.

No daemon, queue, SDK, database beyond notmuch, summaries, server-label sync, or automatic mail actions. Keep Work SMTP for explicitly user-sent mail; Gmail web handles server archive/delete and drafts during pilot. Mailbox remains unchanged. Implement on current non-main branch; record prior Work config for rollback, including untracked `accounts.conf`. Branch rollback alone does not restore private config or runtime data.

## Files to modify

Paths relative to this aerc directory unless absolute/home-relative. Changes below are for implementation, not planning session.

| File | Change |
| --- | --- |
| `../nix/hosts/Macbook-Airborne/default.nix` | Host-specific Home Manager isync/notmuch; Homebrew Ollama |
| `~/.mbsyncrc` | Work-only pull configuration |
| `~/.config/notmuch/work/config` | Work profile and mail root |
| `accounts.conf` | Switch existing Work source to notmuch; preserve SMTP/identity; adjust IMAP-only settings |
| `work-query-map.map` | New local saved searches |
| `aerc.conf` and `binds.conf` | Retarget Work-nm scaffolding to Work; disable Work file operations |
| `../../.bin/mail-triage` | Small Python classifier CLI |
| `../../.bin/tests/` | Focused synthetic classifier tests |

Do not alter shared `home/core.nix` or Mini configuration. Keep credentials, mail, models, and reports outside tracked files. Preserve unrelated working-tree changes.

## Reuse

- `accounts.conf`: Work identity, SMTP settings, credential helper, signature, and address-book command.
- `aerc.conf:558` and `binds.conf:26`: existing Work-nm scaffolding.
- `work-folder-map.map`: current folder naming reference; actual local folder query must be verified.
- `../../.bin/`: existing script location, including aerc helpers.
- `../nix/modules/darwin/apps.nix`: existing Homebrew activation/update configuration.
- `plans/notmuch-mail.md`: earlier research, not implementation instructions. This smaller pilot supersedes its bidirectional-sync and automation recommendations.

## Steps

### Phase 1 – Packages and model

- [ ] Add `pkgs.isync` and `pkgs.notmuch` through Airborne's `homeModules`; add `"ollama"` to existing Homebrew list. Apply usual nix-darwin activation.
- [ ] Verify binaries and Ollama >= 0.35.0. Avoid duplicate Nix/Homebrew Ollama installations.
- [ ] Start Ollama manually on localhost, pull `tev1:4b`, and test `/v1/systemone` with synthetic input. Keep model download separate from Nix activation.

**Checkpoint:** one local typed decision request succeeds.

### Phase 2 – Small pull-only mirror

- [ ] Create private `~/Mail/work`; configure Work-only mbsync using existing Gmail credential helper. Mirror INBOX only initially.
- [ ] Explicitly restrict sync to server-to-local operations and local creation/expiration. No push, remote removal, or remote expunge. Verify syntax against installed mbsync manual.
- [ ] Start with `MaxMessages 200`; understand it is per-mailbox retention, not hard cap. Flagged and normally unread messages are exempt. Inspect dry-run/count before downloading; decide local unread expiration explicitly if needed.
- [ ] List mailboxes, dry-run, then sync manually. No scheduler.
- [ ] Configure Work notmuch profile using traditional `database.path=~/Mail/work` layout. Do not assign default inbox tag to all imported messages; use actual physical-folder query for Inbox. Run `notmuch --profile=work new`.

**Checkpoint:** local messages indexed, useful body searches work, remote mail unchanged.

### Phase 3 – aerc local workspace

- [ ] Back up private `accounts.conf` locally with restrictive permissions. Switch existing `[Work]` to `source=notmuch://work`; retain Work identity/SMTP helper/signature/address book. Replace folder-map/default/folder-sort settings with new query map and matching names. Mailbox stays intact; do not add second Work account.
- [ ] Set `enable-maildir=false`; disable/refuse Work archive/delete/move and postpone/recall operations. Remove Work `copy-to` and physical-folder settings unsupported by this pilot. Gmail supplies server Sent copy for SMTP sends; verify with test message. Use Gmail web for archive/delete/drafts during pilot.
- [ ] Retarget existing Work-nm UI/binding overrides to Work and simple sidebar names. Initial Inbox uses confirmed local `folder:` query. Add Requests, Information, Events, Needs attention, Urgent, and Review views based on AI tags.
- [ ] Verify opening mail, threading, full-text queries, and manual view refresh after indexing/tagging.

**Checkpoint:** aerc has useful local search without destructive local operations.

### Phase 4 – Minimal classifier

- [ ] Write one standard-library Python CLI using `email`, `urllib`, `json`, and `subprocess`. Accept notmuch query, limit (default 20), dry-run default, and explicit `--apply`.
- [ ] Read message IDs/files via notmuch. Use subprocess argument arrays, never interpolate mail/model content into shell commands.
- [ ] Decode subject, sender, recipients, and bounded body text. Prefer plain text; clean HTML fallback. Skip attachments/encrypted mail; expose skipped/truncated inputs. Include Jerid's identity. No links/images fetched. Keep input short for Tev1's practical context limits.
- [ ] Ask separate `noul` questions for request, information, event, and action required from Jerid. Labels may overlap. Ask `score` for urgency with four concrete levels: routine, soon, time-sensitive, urgent. No generated prose or summaries.
- [ ] Validate expected response fields and numeric ranges. Print JSON record per message: identity and raw judgments. On API timeout/error, report and leave tags unchanged.
- [ ] In apply mode, map judgments to fixed allowlist: `ai-request`, `ai-information`, `ai-event`, `ai-needs-action`, `ai-urgent`, `ai-review`, `ai-classified`. Initial thresholds are provisional settings to evaluate, not guarantees. Uncertain cases go to Review.
- [ ] Default query skips `ai-classified`; explicit rerun replaces only classifier-owned tags. Preserve manual tags. Avoid routine logging of message bodies; optional reports stay private and untracked.

**Checkpoint:** dry-run shows typed judgments; apply changes only local AI tags.

### Phase 5 – End-to-end trial

- [ ] Review dry-run results for 20–30 messages: English/Spanish, quoted requests, FYI mail, invitations, overlapping categories. Judge practical accuracy and latency before applying.
- [ ] Apply tags to sample and verify sidebar views. Use manual `triage-done` tag to remove completed items from Needs attention without changing server Inbox.
- [ ] Document three manual operations: sync, index, classify. Always use Work profile consistently.
- [ ] Export tags with `notmuch --profile=work dump` before removing pilot database. Rollback tracked changes on current non-main branch without disturbing unrelated edits; restore private Work IMAP configuration from backup. Stop local tools; preserve mail/tags until explicitly choosing deletion.

**Stop here.** Automation, model comparisons, richer history/thread context, additional taxonomies, and mailbox.org expansion wait until pilot proves useful.

## Verification

- [ ] Package versions and synthetic decision API request succeed.
- [ ] mbsync dry-run/config show no remote writes; mirror size acceptable. Gmail flags/folders unchanged by local reading/tagging.
- [ ] Work searches/opens local mail; Mailbox still works; Work archive/delete/move and drafts operations disabled or refused. Explicit SMTP test succeeds and Gmail Sent shows message; no unsupported local Sent-copy error.
- [ ] Synthetic tests cover malformed API output, timeout, MIME decoding, truncation, tag allowlist, and preservation of manual tags. No private mail committed as fixtures.
- [ ] Dry-run makes no tag changes; apply adds expected tags and saved views show results after refresh.
- [ ] Default rerun skips classified mail; explicit rerun updates only AI tags. Manual `triage-done` clears attention view.

> [!WARNING]
> Email is untrusted input. Model has no tools or execution authority; code accepts only known structured judgments and applies allowlisted local tags. No marking read, moving, deleting, sending, or server labeling. Protect Maildir/index/config/report permissions. Pull-only sync intentionally does not round-trip local read state; keep workflow completion in custom tags.
