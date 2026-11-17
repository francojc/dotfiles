# Arch / Omarchy (Home Manager standalone)

This document describes how the `Omarchy-Air` host works in this flake. Omarchy is
Arch Linux + Hyprland, so it is **not** a NixOS system. Nix manages only the
user environment through a standalone Home Manager configuration; the OS
(kernel, systemd, pacman packages, Hyprland, the Omarchy shell and its theme
engine) stays owned by Omarchy.

## Why standalone Home Manager

The flake has three kinds of host:

| Platform | Builder | Output |
|----------|---------|--------|
| `darwin` | `darwin.lib.darwinSystem` | `darwinConfigurations` |
| `linux`  | `nixpkgs.lib.nixosSystem` | `nixosConfigurations` |
| `arch`   | `home-manager.lib.homeManagerConfiguration` | `homeConfigurations` |

An Arch host must not go through `nixosSystem`: that would try to own the
bootloader, systemd services and system packages, which both fails to build on
Arch and competes with Omarchy. The `mkHomeConfig` builder in `flake.nix`
evaluates `./home` plus the host's `homeModules` only; `hostModules` is ignored.

## Platform routing

`lib/systems.nix` gained `helpers.platformOf`, which lets a host override the
platform implied by its nixpkgs `system`:

```nix
platformOf = host:
  if host ? platform && host.platform != null
  then host.platform
  else supportedSystems.${host.system}.platform;
```

`hosts/Omarchy-Air/default.nix` sets `system = "aarch64-linux"` (a real nixpkgs
system) but `platform = "arch"`, so `filterHostsByPlatform "arch"` selects it
for `homeConfigurations` while `nixosConfigurations` is unaffected.

`isArch` is threaded through `mkSpecialArgs` and is `true` only for this host.
`isLinux` stays `true` (Arch is Linux); `isArch` is the specialization.

## Files

| File | Purpose |
|------|---------|
| `hosts/Omarchy-Air/default.nix` | Host definition: system, `platform = "arch"`, user, theme, `homeModules` |
| `profiles/arch/base.nix` | HM module: `targets.genericLinux`, flake overlay, `allowUnfree`, Omarchy env bootstrap |
| `roles/core/packages-arch.nix` | Arch counterpart to `core.nix`: only packages Omarchy does not ship |
| `roles/core/shell-arch.nix` | Arch zsh: portable shell setup without macOS-isms |
| `roles/core/tmux-arch.nix` | Arch tmux: keybindings/plugins, no theme block |

`home/default.nix` uses `isArch` to choose these instead of the shared/macOS
modules.

## What is intentionally not managed

- **System**: everything. No `environment.systemPackages`, services or
  bootloader. Package installs on the system side use `omarchy pkg add` /
  `pacman` / `yay`.
- **`git.nix`, `kitty.nix`**: Omarchy ships git config and themes kitty. Nix
  would shadow or fight the theme engine.
- **`btop`**: Omarchy themes `btop.theme`; excluded from `arch-core.nix`.
- **Theming**: Omarchy's theme engine regenerates terminal configs, `btop.theme`
  and git colors from `colors.toml` on `omarchy theme set`. The Nix theme system
  is kept only where it is not in the way (`nvim` theme file, WezTerm, Vim).

## Package shadowing

Home Manager's profile precedes `/usr/bin` on `PATH`, so any package listed in
`arch-core.nix` overrides the Omarchy build of the same tool. `arch-core.nix`
therefore lists only what Omarchy does not install — chiefly the Neovim LSP /
formatter / build toolchain — and documents the omissions.

## tmux

`omarchy-theme-set-tmux` themes the **running** server at runtime with
`tmux set-option` (`window-style`, `cursor-colour`) and OSC sequences; it does
not rewrite `~/.config/tmux/tmux.conf`. `roles/core/tmux-arch.nix` keeps the
keybindings and plugins but drops the themed status bar so the two do not
mismatch. `omarchy refresh tmux` **does** overwrite `tmux.conf`; do not run it
while Home Manager manages that file.

## Shell

The login shell can be zsh. Omarchy's scripts all use `#!/bin/bash` (or
`python3`) shebangs, so they are unaffected. The Omarchy environment is injected
by `/etc/profile.d/omarchy.sh`, which zsh does not read; `profiles/arch/
configuration.nix` sources the POSIX `env-bootstrap` from zsh's `profileExtra`
so `OMARCHY_PATH` and the Omarchy `PATH` entries survive. The bash-only rc chain
(`aliases`, `functions`, `inputrc`) is not sourced.

`roles/core/shell-arch.nix` restores the `omarchy` command after sourcing the
shared `aliases.zsh`, which aliases `omarchy` to an SSH helper.

## Usage

```sh
# from ~/.dotfiles/.config/nix
home-manager switch --flake .#Omarchy-Air      # or: just arch Omarchy-Air
```

Build without activating:

```sh
nix build .#homeConfigurations.Omarchy-Air.activationPackage
```

## Migrating the live machine after the rename

Run on Omarchy-Air (the host was previously `omarchy`):

```sh
# Global tools output is now per host
nix profile remove omarchy-global-tools
nix profile install ~/.dotfiles/.config/nix#Omarchy-Air-global-tools

# First switch uses the new host name
home-manager switch --flake ~/.dotfiles/.config/nix#Omarchy-Air
```

SSH key files keep the `omarchy` nickname (`~/.ssh/id_ed25519_omarchy_*`), so existing remotes keep working.

## Two Omarchy hosts

| | `Omarchy-Air` | `Omarchy-Mini` |
|---|---|---|
| Machine | MacBook Air, native dual-boot | try-omarchy VM on Mac-Minicore |
| Profiles | `arch/base` + `arch/native` | `arch/base` + `arch/vm` |
| Roles | `roles` `arch` list (same) | `roles` `arch` list (same) |
| Tweak file | `hosts/Omarchy-Air/local.nix` | `hosts/Omarchy-Mini/local.nix` |
| SSH key nickname | `omarchy` | `omarchymini` |

- **Shared**: `roles/default.nix` (`arch` list), `profiles/arch/base.nix`, `lib/packages/arch.nix`.
- **`native.nix`**: laptop/hardware settings for bare metal. Empty for now.
- **`vm.nix`**: try-omarchy guest notes. It sets `PROJECTS_DIR` for the shared folder (`/Users/jeridf/Projects` on the Mac, mounted at `/mnt/mac`, linked to `~/Projects`). Keep databases, SQLite WAL and build caches on the guest disk.
- **`local.nix`**: per-host manual tweaks, listed last in `homeModules`.
- Each host gets its own `<host>-global-tools` flake output.

```sh
home-manager switch --flake .#Omarchy-Mini   # inside the VM
just arch Omarchy-Mini
```

## Follow-ups

- The shared `home/shell/*.zsh` snippets still contain macOS-only helpers
  (`pbcopy`, Google Drive paths, `dswitch`/`nswitch`). They are harmless on
  Arch (aliases/functions that are simply unused) but could be split per
  platform later.
- `isArch` currently also keeps `wezterm.nix` and `vim.nix`; confirm those are
  wanted on the Omarchy host.
- If `omarchy` ever ships `yazi`/`ffmpeg` etc., prune `arch-core.nix`
  accordingly.
