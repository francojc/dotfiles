# My Nix Darwin/NixOS Configuration

<!--toc:start-->

- [My Nix Darwin/NixOS Configuration](#my-nix-darwinnixos-configuration)
  - [Configuration Structure](#configuration-structure)
  - [Host Configurations](#host-configurations)
  - [Custom Services](#custom-services)
  - [Theme System](#theme-system)
  - [Python Environment](#python-environment)
  - [Flatpak Configuration](#flatpak-configuration)
  - [Documentation](#documentation)
  - [Usage Instructions](#usage-instructions)
  - [Contributions and License](#contributions-and-license)

<!--toc:end-->

> **Note**: This is a personal configuration, and it may not be suitable for you. You can use it as a reference to build your own configuration.

## Configuration Structure

```txt
├── docs
│   ├── README.md
│   └── ollama-hybrid-setup.md
├── flake.lock
├── flake.nix
├── home
│   ├── core.nix
│   ├── default.nix
│   ├── ghostty.nix
│   ├── git.nix
│   ├── i3
│   │   └── default.nix
│   ├── kitty.nix
│   ├── ncspot.nix
│   ├── reddix.nix
│   ├── shell
│   │   ├── aliases.zsh
│   │   ├── default.nix
│   │   └── fzf.zsh
│   ├── sway
│   │   ├── sway.nix
│   │   ├── waybar.nix
│   │   └── wofi.nix
│   ├── syncthing.nix
│   ├── themes.nix
│   ├── tmux.nix
│   ├── vim.nix
│   └── wezterm.nix
├── hosts
│   ├── Mac-Minicore
│   │   └── default.nix
│   ├── Macbook-Airborne
│   │   └── default.nix
│   └── Mini-Rover
│       ├── configuration.nix
│       ├── default.nix
│       └── hardware-configuration.nix
├── Justfile
├── lib
│   └── systems.nix
├── modules
│   ├── darwin
│   │   ├── apps.nix
│   │   ├── copilot-api.nix
│   │   ├── ollama-back.nix
│   │   ├── ollama.nix
│   │   └── reddix.nix
│   ├── nixos
│   │   └── apps.nix
│   └── shared
│       ├── fonts.nix
│       ├── nix-core.nix
│       └── packages.nix
├── profiles
│   ├── darwin
│   │   └── configuration.nix
│   └── nixos
│       ├── configuration.nix
│       ├── i3.nix
│       └── sway.nix
├── README.md
└── templates
    ├── academic-project
    │   └── flake.nix
    └── data-science
        └── flake.nix
```

## Host Configurations

This flake manages three distinct hosts with different hardware platforms and purposes:

| Host | Platform | Theme | Desktop | Services |
|------|----------|-------|---------|----------|
| **Mac-Minicore** | aarch64-darwin (M4 Mac Mini) | ayu | macOS | copilot-api, ollama, reddix |
| **Macbook-Airborne** | aarch64-darwin (MacBook Air M2/M3) | gruvbox | macOS | reddix |
| **Mini-Rover** | x86_64-linux (Mac Mini 2011) | nightfox | i3 (X11) | - |

### Mac-Minicore

Primary development machine running macOS on Apple Silicon (M4 Mac Mini). Configured with the "ayu" theme and runs all custom services:

- **copilot-api**: Token sharing proxy for GitHub Copilot (port 4141, Tailscale accessible)
- **ollama**: Local LLM service via hybrid Homebrew+Nix setup (port 11434, Tailscale accessible)
- **reddix**: Reddit credential injection wrapper

Includes custom keyboard mapping (Fn key → Right Option).

### Macbook-Airborne

Portable development machine running macOS on Apple Silicon (MacBook Air M2/M3). Configured with the "gruvbox" theme. Runs only the **reddix** service for lightweight operation, relying on Mac-Minicore for AI services via Tailscale.

### Mini-Rover

Legacy NixOS workstation running on x86_64 (Mac Mini 2011). Configured with the "nightfox" theme and i3 window manager on X11. This is a pure NixOS configuration without the Darwin-specific services.

## Custom Services

### Copilot API Service

A token sharing proxy for GitHub Copilot that prevents OAuth conflicts when using multiple machines.

- **Module**: `modules/darwin/copilot-api.nix`
- **Port**: 4141 (accessible via Tailscale at 0.0.0.0)
- **Purpose**: Share GitHub Copilot authentication tokens across multiple development machines
- **Active on**: Mac-Minicore only

### Ollama Service

Local LLM inference service using a hybrid Homebrew + Nix approach.

- **Module**: `modules/darwin/ollama.nix`
- **Port**: 11434 (accessible via Tailscale at 0.0.0.0)
- **Approach**: Hybrid setup - Ollama binary managed by Homebrew, configuration managed by Nix
- **Configuration**:
  - 8192 token context window (`OLLAMA_NUM_CTX`)
  - Flash attention enabled (`OLLAMA_FLASH_ATTENTION=1`)
  - Q8_0 quantized KV cache (`OLLAMA_KV_CACHE_TYPE=q8_0`)
  - 4 parallel requests (`OLLAMA_NUM_PARALLEL=4`)
- **Active on**: Mac-Minicore only
- **Documentation**: See `docs/ollama-hybrid-setup.md` for detailed setup and sync procedures

**Important**: This service requires manual synchronization between Nix configuration and the LaunchAgent plist. When updating settings in `hosts/Mac-Minicore/default.nix`, you must manually update `~/Library/LaunchAgents/com.github.ollama.plist` and reload the service.

### Reddix Service

A wrapper service that injects Reddit credentials from the `pass` password manager.

- **Module**: `modules/darwin/reddix.nix`
- **Purpose**: Securely inject Reddit API credentials into applications without storing them in plain text
- **Active on**: Mac-Minicore and Macbook-Airborne

## Theme System

This configuration includes a comprehensive theming system that applies consistent color schemes across all terminal emulators, editors, and TUI applications.

### Available Themes

The configuration supports 11 distinct themes, each with carefully coordinated color palettes:

1. **arthur** - Classic desert-inspired warm tones
2. **autumn** - Rich fall colors with deep browns and oranges
3. **ayu** - Modern bluish-gray color scheme (Ayu Mirage variant)
4. **blackmetal** - High-contrast monochromatic theme
5. **catppuccin** - Popular pastel-inspired color scheme (Mocha variant)
6. **gruvbox** - Retro groove colors with warm contrast
7. **nightfox** - Deep blue night-time color palette
8. **onedark** - Atom editor-inspired dark theme
9. **tokyonight** - Tokyo night cityscape-inspired colors
10. **vague** - Subtle, muted color scheme
11. **vscode** - Visual Studio Code Dark+ theme

### How Themes Work

- **Definition**: All themes are defined in `home/themes.nix` with color palettes and application-specific settings
- **Selection**: Each host declares its theme in `hosts/*/default.nix` (e.g., `theme = "ayu";`)
- **Application**: Themes are applied system-wide to:
  - Terminal emulators (Ghostty, Kitty, WezTerm)
  - Editors (Vim, Neovim)
  - TUI applications (ncspot)
- **Customization**: Each theme includes mappings for application-specific color schemes and cursor colors

To change a host's theme, edit the `theme` attribute in the host's `default.nix` file and rebuild.

## Python Environment

### Three-Layer System

1. **Nix (Base Python)**: Python 3.12 from nixpkgs

   - System-wide interpreter
   - Used by UV as base for tool installations
   - Ensures reproducibility

2. **UV (CLI Tools)**: Modern Python package manager

   - Manages: `aider`, `marker-pdf`, `mlx-lm`, `zotero-mcp`, etc.
   - Uses nix Python via `UV_PYTHON` environment variable
   - Faster than nix packages for rapidly-updating tools

3. **Homebrew (C Libraries)**: System dependencies

   - Provides: `cairo`, `pango`, `gdk-pixbuf`
   - Required for `marker-pdf` DOCX/PPTX conversion
   - Used because UV tools need system-level library paths

### Project Development

Use **nix flakes with direnv** for project environments:

```bash
# Create new project
new-project academic my-research
cd my-research
# Environment loads automatically via direnv
```

*Note*: This the `new-project` command is a custom script defined in and managed by my dotfiles and lives in `~/.bin/`. When adding more project templates, I update this script accordingly.

### When to Use What

- **Nix**: Base packages, LSPs, formatters, CLI utilities
- **UV**: Python CLI tools, custom tools not in nixpkgs
- **Nix flakes**: Project development environments
- **Homebrew**: C libraries for UV tools, GUI apps

### Flatpak Configuration

This configuration includes Flatpak support:

- **Aliases**: Defined in `home/shell/default.nix` for common Flatpak commands (e.g., `flat`, `flat-install`, `flat-search`).
- **Service Enablement**: Flatpak services are enabled in `profiles/nixos/sway.nix`.
- **Repositories**: Configured in `modules/nixos/apps.nix`.
- **Integration**: Uses `nix-flatpak` for managing Flatpak packages, as defined in `flake.nix`.

## Documentation

This configuration includes comprehensive documentation in the `docs/` directory:

- **`docs/README.md`**: Documentation index with quick references for common operations, theme switching, and service management
- **`docs/ollama-hybrid-setup.md`**: Detailed guide for the Ollama hybrid Homebrew + Nix setup, including:
  - Initial installation and configuration
  - LaunchAgent plist setup
  - Manual synchronization procedures
  - Troubleshooting and verification steps
  - Environment variable reference

For detailed information about specific aspects of this configuration, consult these documentation files.

## Usage Instructions

> **Note**: This Nix configuration is housed within my personal dotfiles repository. If you do not plan to use it as-is, please refer to it for inspiration in building your own configuration instead of cloning it directly.

### Prerequisites

1. **Install Nix with flakes enabled**:
   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```

2. **Clone the dotfiles repository**:
   ```bash
   git clone https://github.com/francojc/dotfiles.git ~/.dotfiles
   ```

### For macOS (Darwin Hosts)

This configuration supports two Darwin hosts: `Mac-Minicore` and `Macbook-Airborne`.

1. **Initial setup** (first-time only):
   ```bash
   # Install nix-darwin
   nix run nix-darwin -- switch --flake ~/.dotfiles/.config/nix/#Mac-Minicore
   ```

2. **Apply configuration** (after initial setup):
   ```bash
   darwin-rebuild switch --flake ~/.dotfiles/.config/nix/#Mac-Minicore
   ```

3. **Use the convenience alias** (available after first successful build):
   ```bash
   switch  # Automatically uses the current host's configuration
   ```

**Choose the appropriate hostname**:
- `Mac-Minicore` - For M1 Mac Mini (includes all services: copilot-api, ollama, reddix)
- `Macbook-Airborne` - For MacBook Air M2/M3 (lightweight, reddix only)

### For NixOS (Mini-Rover)

1. **Apply configuration**:
   ```bash
   sudo nixos-rebuild switch --flake ~/.dotfiles/.config/nix/#Mini-Rover
   ```

2. **For Flatpak support** (included in Mini-Rover configuration):
   ```bash
   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   ```

### Common Operations

**Switching themes**:
1. Edit `hosts/<hostname>/default.nix`
2. Change the `theme` attribute to one of the 11 available themes
3. Rebuild: `darwin-rebuild switch --flake ~/.dotfiles/.config/nix/#<hostname>` (or `switch`)

**Updating flake inputs**:
```bash
cd ~/.dotfiles/.config/nix
nix flake update
darwin-rebuild switch --flake .#<hostname>
```

### Contributions and License

Contributions are welcome! Please submit a pull request or open an issue for discussion.

This project is licensed under the MIT License. See the `LICENSE` file for details.
