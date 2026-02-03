# Dotfiles Repository

Nix-based configuration management for macOS (nix-darwin) and NixOS systems.

## Build Commands

Run from `.config/nix/`:

```bash
just darwin    # Build and switch Darwin config
just update    # Update flake.lock
just gc        # Garbage collection
just fmt       # Format Nix files with alejandra
```

Shell aliases (available after config applied):

```bash
dswitch        # darwin-rebuild switch
nswitch        # nixos-rebuild switch
stow .         # Symlink dotfiles from repo root
```

## Architecture

- **Nix Flakes + Home Manager** - Declarative, reproducible configuration
- **Hosts**: Macbook-Airborne, Mac-Minicore (aarch64-darwin), Mini-Rover (x86_64-linux)
- **Package tiers**: Nix (stable CLI tools), UV (Python tools), Homebrew (GUI apps, C libraries)
- **Theme system**: Defined in `themes.nix`, selected per-host in host configs

## Directory Structure

```
.config/nix/
├── flake.nix           # Entry point
├── home/               # Home Manager modules
│   ├── core.nix        # Essential packages
│   ├── shell/          # Zsh, aliases, environment
│   └── themes.nix      # Color schemes, fonts
├── hosts/              # Host-specific configs
│   ├── macbook-airborne/
│   ├── mac-minicore/
│   └── mini-rover/
└── modules/            # System-level modules
    ├── darwin/         # macOS-specific
    ├── nixos/          # NixOS-specific
    └── shared/         # Cross-platform

.bin/                   # Custom shell scripts
```

## Coding Standards

- **Nix**: Format with `alejandra` (run `just fmt`)
- **Commits**: Conventional format - `type(scope): message`
- **R**: Tidyverse, native pipe (`|>`), 2-space indent
- **Python**: Ruff formatting, 4-space indent
- **Bash**: POSIX-compliant, 2-space indent

## Adding Packages

1. **CLI tools**: Add to `.config/nix/home/core.nix`
2. **GUI apps (macOS)**: Add to host's `homebrew.casks` in `.config/nix/hosts/*/default.nix`
3. **Python tools**: Use `uv tool install <package>`

## Common Tasks

**Add a new shell alias**: Edit `.config/nix/home/shell/default.nix`

**Change theme**: Modify `selectedTheme` in the host's config file

**Add a new host**: Create directory in `hosts/`, add to `flake.nix` outputs
