# My Nix Darwin/ NixOS Configuration

<!--toc:start-->

- [My Nix Darwin Configuration](#my-nix-darwin-configuration)
  - [Python Environment Philosophy](#python-environment-philosophy)
  - [Configuration Structure](#configuration-structure)
  - [Flatpak Configuration](#flatpak-configuration)
  - [Usage Instructions](#usage-instructions)
  - [Contributions and License](#contributions-and-license)

<!--toc:end-->

> **Note**: This is a personal configuration, and it may not be suitable for you. You can use it as a reference to build your own configuration.

## Python Environment Philosophy

### Three-Layer System

1. **Nix (Base Python)**: Python 3.12 from nixpkgs

   - System-wide interpreter
   - Used by UV as base for tool installations
   - Ensures reproducibility

2. **UV (CLI Tools)**: Modern Python package manager

   - Manages: `aider`, `marker-pdf`, `mlx-lm`, `zotero-mcp`
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

### When to Use What

- **Nix**: Base packages, LSPs, formatters, CLI utilities
- **UV**: Python CLI tools, custom tools not in nixpkgs
- **Nix flakes**: Project development environments
- **Homebrew**: C libraries for UV tools, GUI apps

## Configuration Structure

```txt
├── flake.lock
├── flake.nix
├── home
│   ├── core.nix
│   ├── default.nix
│   ├── git.nix
│   ├── neovim
│   │   ├── default.nix
│   │   ├── init.lua
│   │   ├── plugin
│   │   └── snippets
│   ├── shell
│   │   ├── aliases.zsh
│   │   ├── default.nix
│   │   └── fzf.zsh
│   └── vim.nix
├── hosts
│   ├── darwin
│   │   └── configuration.nix
│   └── nixos
│       ├── configuration.nix
│       ├── dconf.nix
│       ├── dconf.settings
│       └── hardware-configuration.nix
├── Justfile
├── modules
│   ├── darwin
│   │   └── apps.nix
│   ├── nixos
│   │   └── apps.nix
│   └── shared
│       ├── fonts.nix
│       ├── nix-core.nix
│       └── packages.nix
└── README.md
```

### Flatpak Configuration

This configuration includes Flatpak support:

- **Aliases**: Defined in `home/shell/default.nix` for common Flatpak commands (e.g., `flat`, `flat-install`, `flat-search`).
- **Service Enablement**: Flatpak services are enabled in `profiles/nixos/sway.nix`.
- **Repositories**: Configured in `modules/nixos/apps.nix`.
- **Integration**: Uses `nix-flatpak` for managing Flatpak packages, as defined in `flake.nix`.

### Usage Instructions

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/your-repo.git
   ```

2. Set up Nix:
   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```

3. Use the provided `flake.nix` to configure your system:
   ```bash
   nixos-rebuild switch --flake .
   ```

4. For Flatpak, ensure the service is enabled and repositories are added:
   ```bash
   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   ```

### Contributions and License

Contributions are welcome! Please submit a pull request or open an issue for discussion.

This project is licensed under the MIT License. See the `LICENSE` file for details.