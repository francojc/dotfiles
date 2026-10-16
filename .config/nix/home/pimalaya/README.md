# pimalaya

Pimalaya stack — Mode B (direct, no sync layer). Runs in parallel with
existing aerc + khal + vdirsyncer; does not replace them.

## Layout

| Tool | File | Backend(s) |
|---|---|---|
| himalaya (CLI) | `~/.config/himalaya/config.toml` | IMAP, SMTP |
| himalaya-tui | (same file as above) | IMAP, SMTP |
| cardamum | `~/.config/cardamum/config.toml` | CardDAV |
| calendula | `~/.config/calendula/config.toml` | CalDAV |

Shared secrets via `pass`:

- `EMAIL/GMAIL` → Gmail (francojc@wfu.edu)
- `EMAIL/MAILBOX` → Mailbox.org (thatdude@mailbox.org)

## Activate

Drop into `home/default.nix` alongside the other modules:

```nix
imports = [
  ./themes/themes.nix
  ./document-tools.nix
  ./ssh-aliases.nix
  ./pimalaya # ← add here
];
```

Rebuild: `home-manager switch` (or `darwin-rebuild` on macOS).

## First-run validation

```sh
# email
himalaya account list
himalaya -a gmail envelope list --page-size 5
himalaya -a mailbox envelope list --page-size 5

# contacts
cardamum addressbook list -a mailbox
cardamum -a mailbox card list --page-size 5

# calendar
calendula calendar list -a mailbox
calendula -a mailbox event agenda --today
```

If `addressbook.default` / `calendar.default` ids differ from the defaults
shipped here, edit `cardamum.toml` / `calendula.toml` accordingly.

## Caveats

- Gmail + aerc + himalaya polling same INBOX → cross-client flag thrash
  possible. Set aerc `check-mail` higher if needed.
- Mailbox.org 2FA → per-service app passwords required; split pass entries
  into `EMAIL/MAILBOX-CARDDAV` etc. and update configs.
- Gmail contacts/calendars (the commented `gpeople` / `gcal` blocks) require
  Ortie OAuth broker, a separate Pimalaya-side repo.
