# Personal Scripts and Tools

This directory contains a collection of scripts and tools for automating tasks, improving productivity, and enhancing the development workflow. The scripts are organized by functionality and written in various languages including Bash, Python, Zsh, and AppleScript.

## Categories

### 🎵 Media and Entertainment

- **`am`** - Advanced Apple Music controller with TUI interface, playlist management, and album art display
- **`am-art.applescript`** - AppleScript companion for extracting album artwork from Apple Music

### 🤖 AI and Machine Learning

- **`chat_interface.py`** - Interactive curses-based chat interface for Ollama models
- **`extracty`** - Extract text from images using OpenAI GPT-4o-mini vision model
- **`imagey`** - Generate images using OpenAI's DALL-E API with customizable parameters
- **`myllama`** - Simplified Ollama model launcher with predefined aliases
- **`speechy`** - Convert text to speech using Eleven Labs API with voice selection
- **`transcribe`** - Transcribe audio files using OpenAI's Whisper API

### 🔧 System Utilities

- **`battery_status.sh`** - Display battery status with icons and color-coded output
- **`create-color-wallpaper.sh`** - Generate solid color wallpapers for macOS
- **`switch-mac-addr.sh`** - Utility for changing MAC addresses
- **`weather`** - Get current weather information with emoji icons
- **`weather.sh`** - Alternative weather script
- **`wifi_status.zsh`** - Display WiFi connection status and information

### 🔐 Security and Password Management

- **`import-env-var-pass.sh`** - Import environment variables from pass password store
- **`pass-export.sh`** - Export all pass passwords as shell environment variables
- **`pass-keys.sh`** - Utility for managing pass password store keys
- **`pass-to-env.sh`** - Convert pass entries to environment variables

### 📚 Academic and Teaching Tools

- **`canvas_list_assignments.sh`** - List Canvas course assignments in CSV format
- **`canvas_update_assignments.sh`** - Update Canvas assignment dates and settings
- **`fetch-student-merge`** - Merge student repository changes into instructor branch
- **`fetch-student-remote`** - Fetch changes from student remote repositories
- **`pptx2md.py`** - Convert PowerPoint presentations to Markdown with image extraction

### 🔄 Development and Git Tools

- **`change-git-remote.sh`** - Utility for changing Git remote URLs
- **`get-git-statuses.sh`** - Check Git status across multiple repositories
- **`git-all-acp`** - Add, commit, and push changes across multiple Git repositories
- **`push-pull-request`** - Streamlined pull request creation workflow

### 📁 File and Document Processing

- **`pandoc_watch`** - Watch files and automatically convert with Pandoc
- **`preview_watch`** - Watch and preview document changes
- **`render_watch`** - Watch and render documents automatically
- **`speedlog.sh`** - Fast logging utility

### 🌐 Web and API Tools

- **`google-drive-files.sh`** - Interact with Google Drive files via API
- **`openroute.sh`** - OpenRoute service API interactions
- **`perp.sh`** - Perpetual process management utility

### 📞 Communication and Contacts

- **`personal-contacts-fetcher.py`** - Fetch and manage personal contacts
- **`personal-contacts-setup.sh`** - Setup script for personal contacts management

### 📅 Calendar and Synchronization

- **`ical`** - iCalendar utilities and management
- **`vds`** - vdirsyncer wrapper for calendar synchronization
- **`vm_sync_tool.sh`** - Virtual machine synchronization utility

### 🛠️ Development Environment

- **`flake.nix`** - Nix flake configuration for reproducible development environment
- **`flake.lock`** - Nix flake lock file
- **`.envrc`** - direnv configuration for automatic environment loading

## Usage

Most scripts include built-in help accessible with `-h` or `--help` flags. Many scripts require API keys stored in the `pass` password manager or as environment variables.

### Prerequisites

Common dependencies across scripts:
- `curl` - HTTP requests
- `jq` - JSON processing  
- `pass` - Password management
- `ffmpeg` - Audio/video processing (for some scripts)
- Various API keys (OpenAI, Eleven Labs, Canvas, etc.)

### Environment Setup

The directory includes a Nix flake for reproducible development environments. Use with direnv for automatic environment loading:

```bash
# Enable direnv (if not already done)
direnv allow

# Or manually enter the Nix environment
nix develop
```
