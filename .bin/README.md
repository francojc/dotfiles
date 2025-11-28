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
- Common dependencies: curl, jq, git, gh, ffmpeg, yt-dlp (depending on the script)

## Notes on portability

- Colors auto-disable with NO_COLOR or when stdout is not a TTY

## Development

- Use the common CLI conventions for any new scripts
- Source common for logging, flag parsing, dry-run, and error handling
