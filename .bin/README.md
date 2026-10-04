# Personal Scripts and Tools

This directory contains a flat collection of personal scripts and small tools. The naming is now consistent and concise, using short prefixes by category while preserving your AI tools with their original names.

## Prefix scheme (short and consistent)

- av- = Audio/Video utilities
- clsrm- = Classroom workflows
- cntc- = Contacts
- g- = local Git utilities
- gdrv- = Google Drive
- gh- = GitHub utilities
- net- = Networking
- pdc- = Pandoc / document conversion
- q- = Quarto helpers

## `marker-convert` — multi-format to Markdown

`marker-convert` produces Pandoc Markdown while preserving semantic structure.
It uses Pandoc directly for DOCX, HTML, EPUB, RTF, ODT, and markup formats, and
routes PDFs to `marker_single` for layout-aware extraction and OCR. It no
longer renders semantic documents through an intermediate PDF.

```sh
marker-convert report.docx
marker-convert book.epub --output notes/book.md
marker-convert page.html --output-dir notes
marker-convert scan.pdf --use-llm --gemini_api_key "$GEMINI_API_KEY"
marker-convert report.docx --strip-comments --clean
```

By default output is `./marker_output/<input-stem>.md`; extracted media is kept
in the adjacent `<output-stem>-assets/` directory. Use `--output FILE` for an
exact path or `--output-dir DIR` for a directory. `--engine auto|pandoc|marker`
selects or overrides routing. Marker options can be passed after `--` (or as
unrecognised options); `--use-llm` is opt-in and falls back to local processing
when it is not used or credentials are unavailable. For DOCX-style cleanup,
`--strip-comments` drops source comments (Pandoc route only) and `--clean`
strips a leading BOM, trims trailing whitespace, and collapses runs of blank
lines while leaving fenced and indented code blocks untouched. Both are opt-in.

Pandoc, `marker_single`, and their model dependencies are checked only for the
selected route. `officecli` is not the default exporter: its CLI is a schema-
driven reader/editor for DOCX/XLSX/PPTX, not a Markdown conversion command.
It remains useful for future structured Office inspection. Optional Docling or
MarkItDown installations can be selected explicitly with `--engine` when
available; they are not required for the core Pandoc/Marker routes.
- ssh- = SSH key management
- wx = Weather

AI tools intentionally unchanged: imagey, speechy, extracty, transcribe, ical, myllama, am, vds, chat_interface.py.

## Shared CLI conventions

All Bash scripts follow a common interface:

- Shebang: env bash; safe mode: set -Eeuo pipefail
- NO_COLOR respected: set NO_COLOR to disable colors
- Common flags
  - -h/--help: Show help
  - --version: Show script version
  - -v: Verbose (repeatable)
  - -q: Quiet
  - -n: Dry run (show commands but don’t execute)
  - -C DIR: Change directory before running

Shared helpers are provided in common and automatically sourced by converted scripts.

## Command index by prefix

### g- (Git)

- g-acp — Add/commit/push across immediate child git repos
- g-remote-set — Change a remote URL in the current repo
- g-status — Recursively show git status for nested repos

### gh- (GitHub)

- gh-cop-models — List GitHub Copilot models

### clsrm- (Classroom workflows)

- clsrm-fetch-merge — Wrapper for fetch-student-merge
- clsrm-fetch-remote — Wrapper for fetch-student-remote

### av- (Audio/Video)

- av-dl — Video downloader (yt-dlp), optional subtitles
- av-audio-extract — Extract audio track using ffmpeg
- av-merge — Concatenate videos using ffmpeg concat demuxer
- av-srt — Placeholder wrapper for generating SRT from audio

### net- (Networking)

- net-mac-switch — Wrapper for switch-mac-addr.sh
- net-wifi-status — macOS Wi‑Fi SSID + signal bars (replaces wifi_status.zsh)

### q- (Quarto)

- qlive -- Quarto live preview (entr, render, preview)

### ssh- (SSH key management)

- `ssh-key-setup` – Collision-safe Ed25519 generation with explicit nickname/purpose: `id_ed25519_<nickname>_<purpose>`, comment `<nickname> <purpose>`. Labels match `[a-z][a-z0-9_-]*`; unsafe labels are rejected, not sanitized. Version 2 replaces old identity/service arguments; `-f`/`--force` is rejected, never an overwrite permission.
  - Default performs local generation only; OpenSSH prompts for passphrase. Agent loading (`--load-agent`), clipboard (`--copy`), browser (`--open-url https://...`), and remote smoke test (`--check-remote user@host`) require separate explicit flags. No built-in destination guessing or browser prompts.
  - Refuses private/public collisions, directories, and dangling/live symlinks. Generates in mode-700 staging under SSH directory, then publishes each file with Bash `noclobber`; late regular-file/symlink collisions cannot overwrite existing keys. Publication is not atomic across both files. Failed generation/publication leaves reported partial new paths for manual inspection and explicit cleanup, never automatic deletion of destination paths. Successful staging is removed.
  - Requires trusted, user-controlled SSH directory/ancestor paths. Root SSH-directory symlink is rejected; hostile same-user directory replacement and nonregular-file races are outside this guard. Existing directory permissions remain unchanged; new directories use mode 700, published files mode 600.
  - Stdout contains one JSON registry-entry suggestion after successful publication, also with `--quiet`; diagnostics use stderr. Fingerprint is observed, while creation/review/backup/replacement metadata stays null, authorization list empty, scope incomplete. No runtime/repository registry is read or changed. Review device record and set `replaces` to reviewed old fingerprint before merging rotation suggestion. Opt-in failure exits nonzero but keeps generated pair and emitted suggestion.
  - Remote test ignores user SSH config, agent/default identities, multiplex sessions, and password fallback; requires existing trusted host key, never accepts new host keys or updates trust. Smoke-test result does not populate authorization metadata.
  - Safe examples (no live generation):
    - `ssh-key-setup -n airborne forgejo`
    - `ssh-key-setup -n --replacement-name id_ed25519_airborne_forgejo_2027 airborne forgejo`
    - `ssh-key-setup -n --load-agent --copy --open-url https://codeberg.org/user/settings/keys --check-remote git@codeberg.org airborne codeberg`
  - Replacement name must be distinct `id_ed25519_<nickname>_<purpose>_<suffix>`, suffix `[a-z0-9][a-z0-9_-]*`; original pair remains untouched. Live generation requires separate approval.
  - Isolated tests: `.bin/tests/ssh-key-setup/run.sh`; see adjacent README for interpreter selection and coverage limits.

### google- (Google Drive)

- google-drive-files.sh -- Open Google Drive file list in browser

### cntc- (Contacts)

<!-- FIX: script(s) inside the wrapper are not available. Need to find them in GH or recreate them. -->

- cntc-setup — Wrapper for personal-contacts-setup.sh
- cntc-fetch — Wrapper for personal-contacts-fetcher.py

### wx (Weather)

- wx — Weather dashboard via wttr.in with ASCII art

### Unchanged AI tools

- am — Apple Music controller
- imagey — Image generation tool
- speechy — Text-to-speech
- extracty — Image text extraction
- transcribe — Audio transcription
- ical — Calendar utilities
- myllama — Ollama launcher
- vds — vdirsyncer wrapper

### Other utilities (not yet prefixed)

- openroute — OpenRoute service interactions
- speedlog — Fast logging utility
- create-color-wallpaper — Generate solid color wallpapers
- perp — Perpetual process manager

## Environment variables and dependencies

- gh-cop-models: OPENAI_API_KEY required
- wx: relies on wttr.in (no API key needed)
- ssh-key-setup: Bash 3.2+, `ssh-keygen`, `jq`, and standard file utilities. `SSH_DIR` overrides default `~/.ssh` output directory. `ssh-add`, clipboard tool (`pbcopy`, `xclip`, `xsel`), browser opener (`open`, `xdg-open`), and `ssh` are required only for selected opt-ins; remote timeout fixed at 10 seconds. Dry-run performs validation and collision checks only, without dependency execution, writes, or registry output.
- Common dependencies: curl, jq, git, gh, ffmpeg, yt-dlp (depending on the script)

## Notes on portability

- Colors auto-disable with NO_COLOR or when stdout is not a TTY

## Development

- Use the common CLI conventions for any new scripts
- Source common for logging, flag parsing, dry-run, and error handling
