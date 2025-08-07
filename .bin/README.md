# Personal Scripts and Tools

This directory contains a flat collection of personal scripts and small tools. The naming is now consistent and concise, using short prefixes by category while preserving your AI tools with their original names.

## Prefix scheme (short and consistent)

- g- = local Git utilities
- gh- = GitHub utilities
- cnvs- = Canvas (LMS)
- clsrm- = Classroom workflows
- av- = Audio/Video utilities
- net- = Networking
- vm- = VM and sync
- pdc- = Pandoc / document conversion
- q- = Quarto helpers
- gdrv- = Google Drive
- cntc- = Contacts
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

Shared helpers are provided in common.sh and automatically sourced by converted scripts.

## Command index by prefix

### g- (Git)

- g-acp — Add/commit/push across immediate child git repos
- g-status — Recursively show git status for nested repos
- g-remote-set — Change a remote URL in the current repo

Legacy names remain as symlinks (e.g., git-all-acp -> g-acp; get-git-statuses.sh -> g-status; change-git-remote.sh -> g-remote-set).

### gh- (GitHub)

- gh-pr — Push current branch and create a pull request
- gh-cop-models — List GitHub Copilot models
- gh-mcp-setup — Wrapper for MCP repos setup (delegates to setup-mcp-repos-gh.sh)

### cnvs- (Canvas)

- cnvs-assign-ls — List assignments for a course to CSV template
- canvas_update_assignments.sh — Update assignment dates (portable date conversion)

Note: cnvs-assign-upd may be added later; for now keep using canvas_update_assignments.sh.

### clsrm- (Classroom workflows)

- clsrm-fetch-merge — Wrapper for fetch-student-merge
- clsrm-fetch-remote — Wrapper for fetch-student-remote

### av- (Audio/Video)

- av-yt-dl — Video downloader (yt-dlp), optional subtitles
- av-audio-extract — Extract audio track using ffmpeg
- av-merge — Concatenate videos using ffmpeg concat demuxer
- av-srt — Placeholder wrapper for generating SRT from audio

Legacy names remain as symlinks (dl-youtube.sh, extract-audio.sh, merge-videos.sh, audio-to-srt.sh).

### net- (Networking)

- net-wifi-status — macOS Wi‑Fi SSID + signal bars (replaces wifi_status.zsh)
- net-mac-switch — Wrapper for switch-mac-addr.sh

### vm- (VM / sync)

- vm-sync — Wrapper for vm_sync_tool.sh

### pdc- (Pandoc / conversion)

- pdc-watch — Wrapper for pandoc_watch
- pdc-pptx2md — Wrapper for pptx2md.py

### q- (Quarto)

- q-prev — Wrapper for preview_watch
- q-render — Wrapper for render_watch

### gdrv- (Google Drive)

- gdrv-ls — Wrapper for google-drive-files.sh

### cntc- (Contacts)

- cntc-setup — Wrapper for personal-contacts-setup.sh
- cntc-fetch — Wrapper for personal-contacts-fetcher.py

### wx (Weather)

- wx — Weather dashboard via wttr.in with ASCII art

Legacy names weather and weather.sh point to wx. You’ll see a one-line note when using the old names.

### Unchanged AI tools

- am — Apple Music controller
- imagey — Image generation tool
- speechy — Text-to-speech
- extracty — Image text extraction
- transcribe — Audio transcription
- ical — Calendar utilities
- myllama — Ollama launcher
- vds — vdirsyncer wrapper
- chat_interface.py — TUI chat interface

### Other utilities (not yet prefixed)

- openroute.sh — OpenRoute service interactions
- speedlog.sh — Fast logging utility
- create-color-wallpaper.sh — Generate solid color wallpapers
- perp.sh — Perpetual process manager

These can be grouped later (e.g., sys- or ors-) if desired.

## Environment variables and dependencies

- Canvas scripts: CANVAS_API_KEY and CANVAS_BASE_URL required
- gh-cop-models: OPENAI_API_KEY required
- wx: relies on wttr.in (no API key needed)
- Common dependencies: curl, jq, git, gh, ffmpeg, yt-dlp (depending on the script)

## Backward compatibility

- Older names remain as symlinks to the new short names
- Some scripts print a brief deprecation notice when invoked via the old name
- Update your aliases and automations at your pace; the symlinks can be removed later

## Notes on portability

- Canvas date conversion is now portable across macOS (BSD date) and Linux (GNU date)
- Colors auto-disable with NO_COLOR or when stdout is not a TTY

## Development

- Use the common CLI conventions for any new scripts
- Source common.sh for logging, flag parsing, dry-run, and error handling
