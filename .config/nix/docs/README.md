# Nix Configuration Documentation

This directory contains documentation for the nix-darwin configuration.

## Available Documentation

### Service Configuration

- [**Ollama Hybrid Setup**](ollama-hybrid-setup.md) - Complete guide for the Homebrew + Nix Ollama configuration
  - Manual sync procedure
  - Environment variable mappings
  - Troubleshooting guide
  - Performance notes

## Quick Reference

### Ollama Configuration

When modifying Ollama settings in `hosts/Mac-Minicore/default.nix`:

1. Update Nix config
2. Run `darwin-rebuild switch`
3. Update `~/Library/LaunchAgents/com.github.ollama.plist`
4. Reload: `launchctl unload/load ~/Library/LaunchAgents/com.github.ollama.plist`

See [ollama-hybrid-setup.md](ollama-hybrid-setup.md) for details.

## Configuration Structure

```
~/.dotfiles/.config/nix/
├── flake.nix                    # Main flake configuration
├── hosts/                       # Host-specific configurations
│   └── Mac-Minicore/
│       └── default.nix          # Mac-Minicore settings
├── modules/                     # Reusable modules
│   └── darwin/
│       ├── ollama.nix          # Ollama service module
│       └── ...
├── profiles/                    # Configuration profiles
└── docs/                        # Documentation (you are here)
```

## Getting Help

- Check the inline comments in configuration files
- Review module definitions in `modules/darwin/`
- Consult this documentation directory
