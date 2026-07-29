# Plan: notmuch + mbsync local mail for Work Gmail (Mac Mini only)

## Context

aerc currently talks directly to Gmail IMAP for the Work account
(`francojc@wfu.edu` via imap.gmail.com) and to mailbox.org for personal mail.
Goals:

- Fast local full-text search via notmuch (body + headers, ms latency).
- Better address completion later via `notmuch address` (name + address for
  anyone ever corresponded with).
- Bound local disk usage using mbsync `MaxMessages` (count cap, keeps newest —
  chosen over date-window/label approaches for simplicity).
- Mini only, initially. Airborne untouched. Existing Gmail IMAP account in aerc
  stays configured as fallback and for deep-archive access. Zero risk to Gmail.

Current status:

- aerc 0.21.0 built `+notmuch` (backend compiled in already).
- Neither `isync` (mbsync) nor `notmuch` installed.
- Packages managed via nix home-manager (`~/.config/nix/home/core.nix`).
- Credentials via `pass` (`pass show EMAIL/GMAIL` already used by aerc).
- aerc configs live in this repo at `.config/aerc/`.
- Work account excludes folders: `Archive-old,Drafts-old,Sent-old,Trash-old,[Gmail]Trash`.

## Approach

mbsync mirrors Work Gmail → local maildir (`~/Mail/work`), capped with
`MaxMessages`. notmuch indexes the maildir; a launchd agent runs sync + index
every 5 min. New aerc account `[Work-nm]` uses the notmuch backend with a
`query-map` mirroring the current folder layout. IMAP accounts remain
configured; notmuch account added alongside, not replacing.

## Files to modify / create

- `~/.config/nix/home/core.nix` — add `isync`, `notmuch` packages.
- `~/.mbsyncrc` (new).
- `~/.notmuch-config` (new).
- `.config/aerc/accounts.conf` (this repo) — add `[Work-nm]` section.
- `.config/aerc/work-query-map.map` (new, this repo) — notmuch queries per
  virtual folder.
- `~/Library/LaunchAgents/edu.wfu.mailsync.plist` (new) — or home-manager
  `launchd.agents` entry; decide during implementation.
- `.bin/mailsync-work` (new, this repo) — single script: mbsync + `notmuch new`,
  invoked by launchd.

## Reuse

- `pass show EMAIL/GMAIL` — existing cred command, reused as mbsync `PassCmd`.
- Folder naming conventions from `.config/aerc/work-folder-map.map` — mirror in
  query-map.
- `aerc-emailbook` — stays as-is for now; optional later swap to
  `notmuch address`-based wrapper.

## Steps

### Phase 1 — Packages & skeleton

- [ ] Add `isync` and `notmuch` to `mediaDocumentPackages` in
  `~/.config/nix/home/core.nix`; `home-manager switch`; verify
  `mbsync --version`, `notmuch --version`.
- [ ] Create `~/Mail/work` (maildir root).
- [ ] Estimate remote size: mbsync `--list` / dry run to sanity-check folder
  set before full sync.

### Phase 2 — mbsync config (`~/.mbsyncrc`)

- [ ] `IMAPAccount work`: imap.gmail.com:993, user `francojc@wfu.edu`,
  `PassCmd "pass show EMAIL/GMAIL"`, SSLType IMAPS, AuthMechs to match current
  aerc login (plain password over TLS).
- [ ] `MaildirStore work-local`: `Path ~/Mail/work/`, `Inbox ~/Mail/work/Inbox`,
  `SubFolders Verbatim` (Gmail label fidelity).
- [ ] `Channel work`: `Far :work:`, `Near :work-local:`, `Patterns` excluding
  `[Gmail]/Trash`, `[Gmail]/Bin`, and the `*-old` folders already excluded in
  aerc. `Sync All`, `Expunge Near`, `Create Near`, `SyncState *`.
- [ ] `MaxMessages N` on the channel — pick N after Phase 1 size estimate
  (start 1000 for a quick functional trial; raise once behavior confirmed).
- [ ] Initial sync: `mbsync work`. Expect long first run. Verify message counts,
  spot-check recent + old boundary, confirm flags (read/answered) survive.

### Phase 3 — notmuch setup

- [ ] `notmuch setup` → database path `~/Mail/work/.notmuch`. Set name/email.
- [ ] `notmuch new` — initial index (long first run).
- [ ] Post-new hook `~/Mail/work/.notmuch/hooks/post-new`: tag conventions —
  e.g. `notmuch tag +inbox -- tag:new AND folder:INBOX`,
  `+sent -- folder:"Sent*"`, `-new -- tag:new`. Mirror Gmail folder structure.
- [ ] Smoke tests: `notmuch search from:claudia`,
  `notmuch search body:syllabus date:2w..`, confirm display names match.

### Phase 4 — aerc notmuch account

- [ ] Add to `accounts.conf`:
  ```ini
  [Work-nm]
  source = notmuch://~/Mail/work
  from   = Jerid Francom <francojc@wfu.edu>
  outgoing = smtps://francojc@wfu.edu@smtp.gmail.com:465
  outgoing-cred-cmd = pass show EMAIL/GMAIL
  query-map = ~/.config/aerc/work-query-map.map
  signature-file = ~/.config/aerc/work-signature.md
  address-book-cmd = aerc-emailbook work %s
  ```
- [ ] Create `work-query-map.map` mapping virtual folders to queries, mirroring
  current folder-sort order: `Inbox=tag:inbox`, `Starred=tag:flagged`,
  `Sent=tag:sent`, plus saved searches worth having (`todo`, lists, etc.).
- [ ] Launch `aerc`, switch to Work-nm, verify: list views, open messages,
  thread view, `:filter from:<name>` full-text search, compose+send (SMTP
  unchanged), archive/delete keybinds under notmuch semantics (document
  differences).

### Phase 5 — Automation (launchd)

- [ ] `.bin/mailsync-work`: `mbsync work && notmuch new`, logging to
  `~/.local/state/mailsync-work.log`, flock-guarded against overlap.
- [ ] launchd agent: StartInterval 300s, run script, stdout/stderr to log.
  Load + verify it fires; check log after two cycles.
- [ ] Confirm flag propagation both ways: mark read in aerc-nm → sync → visible
  read in Gmail web / aerc IMAP account.

### Phase 6 — Evaluation & optional upgrades (decision points only)

- [ ] Live with it ≥ 1 week alongside IMAP account.
- [ ] Optional: switch `address-book-cmd` to `notmuch address`-backed script for
  full-history completions (name+address output).
- [ ] Decide: extend to mailbox.org account? Extend to Airborne (muchsync, Mini
  as hub)? Retire Work IMAP account in aerc?

## Verification (end-to-end)

1. `mbsync work` exits 0; `~/Mail/work` populated; local count ≈ min(remote,
   MaxMessages).
2. `notmuch count '*'` ≈ synced count; searches by sender name/body return
   expected hits.
3. aerc Work-nm: browse, search, read, send test mail to self; flags round-trip
   to Gmail after sync cycle.
4. launchd: log shows successful 5-min cycles; no overlapping runs.
5. Rollback test: nothing in Gmail changed unexpectedly; removing configs
   restores exact prior state (IMAP account never modified).

## Rollback

Everything additive. Add `.bin/notmuch-uninstall` (new, this repo) as part of
Phase 5 — one-command rollback that:

1. Unloads + deletes launchd agent
   (`launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/edu.wfu.mailsync.plist`,
   remove plist).
2. Comments out / removes `[Work-nm]` block from `accounts.conf` (marker
   comments `# >>> notmuch` / `# <<< notmuch` around the block make this safe
   and scriptable).
3. Deletes `~/Mail/work`, `~/.notmuch-config`, `~/.mbsyncrc`,
   `work-query-map.map` (git-restorable anyway).
4. Prints reminder of the two manual leftovers: remove `isync`/`notmuch` from
   `core.nix` + `home-manager switch` (script does NOT run home-manager itself).

Gmail and existing aerc setup untouched throughout. Script idempotent; safe to
re-run.
