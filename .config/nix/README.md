# My Nix Darwin/NixOS/Omarchy Configuration

<!--toc:start-->

- [My Nix Darwin/NixOS/Omarchy Configuration](#my-nix-darwinnixosomarchy-configuration)
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
├── flake.lock
├── flake.nix
├── docs
│   └── arch-omarchy.md
├── home
│   ├── arch-core.nix
│   ├── core.nix
│   ├── default.nix
│   ├── document-tools.nix
│   ├── git.nix
│   ├── gnome.nix
│   ├── kitty.nix
│   ├── pimalaya
│   ├── shell
│   ├── ssh-aliases.nix
│   ├── ssh-key-paths.nix
│   ├── syncthing.nix
│   ├── themes
│   │   └── themes.nix
│   ├── tmux.nix
│   ├── vim.nix
│   └── wezterm.nix
├── hosts
│   ├── Mac-Minicore
│   ├── Macbook-Airborne
│   ├── Mini-Rover
│   └── omarchy
├── Justfile
├── lib
│   ├── packages
│   └── systems.nix
├── modules
│   ├── arch
│   ├── darwin
│   ├── nixos
│   └── shared
├── pkgs
├── profiles
│   ├── arch
│   ├── darwin
│   └── nixos
├── README.md
└── templates
    ├── academic-project
    └── data-science
```

## Host Configurations

This flake manages four hosts (two nix-darwin, one NixOS, one Arch/Omarchy) with different hardware platforms and purposes:

| Host | Platform | Theme | Desktop | Services |
|------|----------|-------|---------|----------|
| **Mac-Minicore** | aarch64-darwin (M4 Mac Mini) | gruvbox | macOS | - |
| **Macbook-Airborne** | aarch64-darwin (MacBook Air M2/M3) | gruvbox | macOS | - |
| **Mini-Rover** | x86_64-linux (Mac Mini 2011) | ayu | GNOME (X11) | - |
| **omarchy** | aarch64-linux (Arch Linux + Hyprland) | tokyonight | Omarchy (Home Manager standalone) | - |

### Mac-Minicore

Primary development machine running macOS on Apple Silicon (M4 Mac Mini). Configured with the "gruvbox" theme and runs the custom services (Copilot API proxy and the llama.cpp chat, embedding and FIM servers).

Includes custom keyboard mapping (Fn key → Right Option).

### Macbook-Airborne

Portable development machine running macOS on Apple Silicon (MacBook Air M2/M3). Configured with the "gruvbox" theme. Runs only the Copilot API proxy, relying on Mac-Minicore for local model servers via Tailscale.

### Mini-Rover

Legacy NixOS workstation running on x86_64 (Mac Mini 2011). Configured with the "ayu" theme and the GNOME desktop (`home/gnome.nix`). This is a pure NixOS configuration without the Darwin-specific services.

### omarchy

Arch Linux + Hyprland desktop managed by [Omarchy](https://omarchy.org/). Unlike the other Linux hosts, this is **not** a NixOS system: Omarchy owns the OS, and Nix manages only the user environment through a standalone Home Manager configuration (`homeConfigurations.omarchy`). The host sets `platform = "arch"` to route it away from `nixosConfigurations`, and `home/default.nix` uses `isArch` to select Arch-adjusted modules (`home/arch-core.nix`, `modules/arch/`) that avoid shadowing Omarchy's packages and fighting its theme engine. See [`docs/arch-omarchy.md`](docs/arch-omarchy.md) for the full design.

## Custom Services

### Copilot API Service

A token sharing proxy for GitHub Copilot that prevents OAuth conflicts when using multiple machines.

- **Module**: `modules/darwin/copilot-api.nix`
- **Port**: 4141 (accessible via Tailscale at 0.0.0.0)
- **Purpose**: Share GitHub Copilot authentication tokens across multiple development machines
- **Active on**: Mac-Minicore and Macbook-Airborne

## Theme System

This configuration includes a comprehensive theming system that applies consistent color schemes across all terminal emulators, editors, and TUI applications.

### Available Themes

The configuration supports 13 themes: `arthur`, `ayu`, `blackmetal`, `catppuccin`, `gruvbox`, `iceberg`, `kanso`, `nightfox`, `onedark`, `tender`, `tokyonight`, `vague`, and `vscode`. Each has a coordinated color palette; wallpapers live in `home/themes/images/`. On Omarchy hosts, Omarchy's own theme engine owns most theming (see `docs/arch-omarchy.md`).

### How Themes Work

- **Definition**: All themes are defined in `home/themes/themes.nix` with color palettes and application-specific settings
- **Selection**: Each host declares its theme in `hosts/*/default.nix` (e.g., `theme = "ayu";`)
- **Application**: Themes are applied system-wide to:
  - Terminal emulators (Kitty, WezTerm)
  - Editors (Vim, Neovim)
  - TUI applications (ncspot)
- **Customization**: Each theme includes mappings for application-specific color schemes and cursor colors

To change a host's theme, edit the `theme` attribute in the host's `default.nix` file and rebuild.

## AI Commit Workflow

`pi-commit`, defined in `home/shell/ai.zsh`, sends the staged Git diff to Pi and commits its generated Conventional Commit message. Pi runs once with no tools, extensions, project context, or saved session; Git creates the commit and runs normal hooks. The configured Pi model and credentials must work without extension-provided model registration.

```zsh
gaa && pi-commit && gpl && gp
# Equivalent shortcut:
gaclp
```

The chain stops on failure, including an empty index, invalid model output, changed staged contents, or failed commit hooks. Unstaged changes are excluded. Staged contents are sent to the configured model provider; no saved session does not imply no provider-side retention. Legacy chat-history ignore rules remain to prevent accidental staging of old logs.

After deploying the shell configuration, start a new shell. To load only this function into the current shell immediately:

```zsh
source ~/.config/nix/home/shell/ai.zsh
alias gaclp='gaa && pi-commit && gpl && gp'
```

## Python Environment

### Three-Layer System

1. **Nix (Base Python)**: Python 3.12 from nixpkgs

   - System-wide interpreter
   - Used by UV as base for tool installations
   - Ensures reproducibility

2. **UV (CLI Tools)**: Modern Python package manager

   - Manages: `marker-pdf`, `mlx-lm`, `zotero-mcp`, etc.
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
- **Service Enablement**: Flatpak services are enabled in `modules/nixos/apps.nix`.
- **Repositories**: Configured in `modules/nixos/apps.nix`.
- **Integration**: Uses `nix-flatpak` for managing Flatpak packages, as defined in `flake.nix`.

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
- `Mac-Minicore` - For M1 Mac Mini M4
- `Macbook-Airborne` - For MacBook Air M3

### For NixOS (Mini-Rover)

1. **Apply configuration**:
   ```bash
   sudo nixos-rebuild switch --flake ~/.dotfiles/.config/nix/#Mini-Rover
   ```

2. **For Flatpak support** (included in Mini-Rover configuration):
   ```bash
   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   ```

### For Arch / Omarchy

Omarchy is Arch Linux + Hyprland. Install Nix (the [Determinate Systems installer](https://docs.determinate.systems/) is recommended), then apply the standalone Home Manager configuration. This does not touch the OS; it only links the user environment.

1. **Install Nix** (Determinate Systems, multi-user):
   ```bash
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Apply the configuration**:
   ```bash
   home-manager switch --flake ~/.dotfiles/.config/nix#omarchy
   # or, from the nix directory: just omarchy
   ```

3. **Build without activating**:
   ```bash
   nix build .#homeConfigurations.omarchy.activationPackage
   ```

The host lives in `hosts/omarchy/default.nix`. System packages stay managed by Omarchy (`omarchy pkg add`, `pacman`, `yay`); only packages Omarchy does not ship are installed by Nix. See [`docs/arch-omarchy.md`](docs/arch-omarchy.md).

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
