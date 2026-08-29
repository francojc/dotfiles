# NixOS Quattro Lab Plan and Parallels Guide

> **Status:** proof of concept, installed and validated on Parallels Desktop 27 / Apple Silicon. This adds a separate `aarch64-linux` NixOS host. It does not alter either nix-darwin host.

## Goal

Create an Apple-Silicon-friendly NixOS desktop lab that recreates useful parts of Omarchy Quattro without porting Omarchy or Arch/x86_64 assumptions:

- Hyprland for a keyboard-first Wayland compositor and workspaces;
- Quickshell for one small desktop-shell process;
- a coherent theme shared with Kitty, terminal, and editor configuration;
- lock, idle, portal, launcher, clipboard, notification, screenshot, and audio helpers;
- a rollbackable, flake-based configuration suitable for a Parallels Desktop ARM guest.

## Current flake integration

The POC uses the repository's established host model:

- `lib/systems.nix` declares `aarch64-linux`.
- `flake.nix` builds `nixosConfigurations` from host definitions.
- `home/themes/themes.nix` passes selected palette as `theme` module argument.
- `nixos-quattro` selects `ayu`, imports shared NixOS baseline, and adds Hyprland/Quickshell profile.
- `hosts/nixos-quattro/configuration.nix` uses systemd-boot with `boot.loader.timeout = 0` because Parallels UEFI can stall systemd-boot's interactive timeout screen.

POC files:

```text
hosts/nixos-quattro/default.nix       # aarch64 host declaration
hosts/nixos-quattro/configuration.nix # guest boot, filesystem, user policy
profiles/nixos/quattro.nix            # system Hyprland, portal, Kitty, packages
home/quattro.nix                      # Hyprland bindings, display, idle, Quickshell panel
```

The Home Manager-generated `~/.config/quickshell/shell.qml` is a meaningful vertical slice: it uses Quickshell's Hyprland integration for live workspaces, uses `SystemClock` rather than spawning `date`, and exposes typed IPC commands (`qs ipc call bar workspace 2`, `qs ipc call bar toggle`). Add tray, notifications, media, power, and launcher UI one feature at a time.

## POC feature map

| Quattro concept | This POC | Known limit / next iteration |
|---|---|---|
| Tiling/window workflow | Hyprland bindings, workspaces, focus and move commands | app rules, scratchpads, monitor-specific layout |
| Single shell process | Quickshell starts from Hyprland | tray, notification daemon, menu and IPC |
| Themed desktop | Host-selected theme colors | declarative wallpaper, font, spacing tokens |
| Terminal | Kitty on `Super+Return` | Ghostty needs OpenGL 4.3; Parallels Linux VirGL exposes OpenGL 4.0 in this VM |
| Launcher | Fuzzel (`Super+Space`) | Quickshell launcher panel, retain Fuzzel fallback |
| Notifications | SwayNotificationCenter | Quickshell notification server after UX design |
| Lock/idle | Hyprlock + Hypridle | visual lock theme and suspend policy |
| Display | VirtIO GPU, VirGL, `2560x1600@59.97`, scale `1.6` | host/guest resize policy and per-Mac overrides |
| Desktop plumbing | portals, PipeWire, NetworkManager applet, clipboard history | host sharing and workflow-specific widgets |

## Parallels Desktop setup

### 1. Create ARM guest

On Apple Silicon Mac:

1. In Parallels, create VM with **Install Windows or another OS from a DVD or image file**.
2. Select current **NixOS `aarch64-linux` installer ISO**. Official NixOS minimal image works, as does Determinate Systems installer ISO: `https://install.determinate.systems/nixos-iso/stable/aarch64-linux`. ISO is bootstrap environment only; installed guest comes from flake. Do not use x86_64 image.
3. Start with 4 vCPU, 8 GiB RAM, and 60–80 GiB disk.
4. Enable 3D acceleration.
5. In Parallels **Settings → Shortcuts → macOS System Shortcuts**, set **Send macOS system shortcuts** to **Always**. In Parallels terminology, **Always** forwards macOS shortcuts to active guest; **Never** keeps them in macOS.
6. Use NAT initially. Authenticate Tailscale only after first successful graphical login if remote access is wanted.

Keep macOS as host desktop. Guest is contained Wayland lab, not replacement for macOS compositor or security model.

### 2. Normalize Parallels virtual hardware

Parallels can silently suspend a VM when window closes. Hardware changes only apply after real stop. Do not hand-edit `config.pvs`; use supported `prlctl` commands.

Before changing VM hardware, from macOS Terminal:

```bash
VM=NixOS # replace with Parallels VM name
prlctl list -a
```

Proceed only when VM state is `stopped`. If guest is stuck and cannot shut down cleanly, `prlctl stop "$VM" --kill` is forced power-off and can lose unwritten data.

Use SATA for disk and CD-ROM. IDE disk attachment did not appear in this ARM guest even though Parallels reported it connected. Configure disk at SATA port 0, enable VirtIO graphics, and retain ISO as fallback at SATA port 1:

```bash
prlctl set "$VM" --device-set hdd0 --iface sata --position 0
prlctl set "$VM" --video-adapter-type virtio --3d-accelerate highest
prlctl set "$VM" --device-bootorder "hdd0 cdrom0"
prlctl list "$VM" -i
```

Expected relevant lines:

```text
video adapter-type=virtio ... 3d-acceleration=highest
hdd0 (+) sata:0 ...
cdrom0 (+) sata:1 ...
Boot order: hdd0 cdrom0
```

For ISO recovery, stop VM, attach ISO, and temporarily put `cdrom0` first:

```bash
prlctl set "$VM" --device-bootorder "cdrom0 hdd0"
```

Restore `hdd0 cdrom0` after recovery. An ISO list can show duplicate names from recent-source history. Check configured image path with `prlctl list "$VM" -i`; only connected `cdrom0` matters.

### 3. Partition and install NixOS

Boot ISO. Confirm both disk and ISO appear before partitioning:

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL
```

Expected Parallels layout for this guide:

```text
sda    64G disk
sr0   ... rom  nixos-...
```

**Commands below erase selected disk.** Verify disk name first. This guide uses SATA disk `/dev/sda`; do not blindly reuse it if `lsblk` differs.

POC expects:

- EFI System Partition mounted at `/mnt/boot`;
- ext4 root labeled `nixos`, mounted at `/mnt`.

```bash
sudo -i
export DISK=/dev/sda # replace only after verifying with lsblk
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary ext4 512MiB 100%
mkfs.fat -F 32 -n EFI "${DISK}1"
mkfs.ext4 -L nixos "${DISK}2"
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/EFI /mnt/boot
findmnt /mnt /mnt/boot
```

The POC currently lives on its remote branch. Clone that branch, not default branch:

```bash
mkdir -p /mnt/home/jeridf
git clone --branch hermes/nixos-quattro-parallels-poc --single-branch https://github.com/francojc/dotfiles.git /mnt/home/jeridf/.dotfiles
cd /mnt/home/jeridf/.dotfiles/.config/nix
nixos-install --flake .#nixos-quattro
```

Installer prompts for installed system's root password. Set it. Do not reboot yet: flake creates `jeridf` but deliberately does not commit a password to repository.

```bash
nixos-enter --root /mnt
passwd jeridf
chown -R jeridf:users /home/jeridf/.dotfiles
exit
poweroff
```

After VM is stopped, restore normal disk-first boot order before starting it:

```bash
prlctl set "$VM" --device-bootorder "hdd0 cdrom0"
prlctl start "$VM"
```

### 4. First boot, graphics, and display

Normal boot skips systemd-boot menu and starts default generation immediately. `boot.loader.timeout = 0` avoids Parallels UEFI's unreliable interactive timeout path. Use ISO recovery if bootloader or graphics configuration leaves system unbootable.

1. Log in at `tuigreet`; it starts Hyprland.
2. Open Kitty with `Super+Return`; open Fuzzel with `Super+Space`.
3. Verify VirtIO GPU and VirGL from graphical session or TTY:

   ```bash
   sudo dmesg | grep -Ei 'virgl|virtio.*gpu'
   lsmod | grep virtio_gpu
   hyprctl monitors
   ```

   Expected kernel signals:

   ```text
   [drm] features: +virgl ...
   Initialized virtio_gpu ...
   ```

4. Verify renderer from graphical Kitty:

   ```bash
   nix shell nixpkgs#mesa-demos -c glxinfo -B | grep -E 'OpenGL vendor|OpenGL renderer|OpenGL version'
   ```

   Do not expect Ghostty to work with this accelerated Parallels path. Current VM reports OpenGL 4.0, while Ghostty requires 4.3. [Parallels' Linux documentation](https://kb.parallels.com/en/124138) guarantees OpenGL 3.3; its [Parallels 27 OpenGL 4.3 announcement](https://kb.parallels.com/en/115487) applies to Windows guests. [VirGL is expected for new ARM Linux VMs](https://kb.parallels.com/en/128518). Kitty works within available OpenGL capability.

5. `home/quattro.nix` persists this tested display mode:

   ```text
   Virtual-1,2560x1600@59.97,auto,1.6
   ```

   It is 16:10. Inspect available modes with `hyprctl monitors`; test changes live with `hyprctl keyword monitor "Virtual-1,<mode>,auto,<scale>"` before committing another mode.

6. Run `hyprctl reload` only inside graphical Hyprland session. A TTY lacks `HYPRLAND_INSTANCE_SIGNATURE` and cannot address running compositor.

Clipboard integration, shared folders, camera/microphone, and suspend remain separate host-integration work. Verify each independently.

## Updating installed guest

From graphical Kitty:

```bash
cd ~/.dotfiles/.config/nix
git pull --ff-only
sudo nixos-rebuild build --flake .#nixos-quattro
sudo nixos-rebuild switch --flake .#nixos-quattro
hyprctl reload
```

Run `hyprctl reload` after Home Manager changes to Hyprland settings. Use a graphical terminal, not TTY.

## Validation plan

1. Format source:

   ```bash
   nix fmt flake.nix hosts/nixos-quattro/ home/quattro.nix profiles/nixos/quattro.nix
   ```

2. Evaluate host:

   ```bash
   nix eval .#nixosConfigurations.nixos-quattro.config.system.build.toplevel.drvPath
   ```

3. Verify guest: `hyprctl monitors`, Quickshell panel, `loginctl`, `systemctl --user status hypridle`, clipboard history, launcher, lock, audio keys, screenshot command.
4. Verify virtual graphics: `+virgl`, loaded `virtio_gpu`, non-`llvmpipe` renderer, expected `Virtual-1` display mode.
5. Verify Kitty opens with `Super+Return`. Ghostty failure with `OpenGLOutdated` is expected on this Parallels Linux VirGL stack, not a Quattro configuration failure.
6. Roll back a bad activation from graphical session or TTY with `sudo nixos-rebuild switch --rollback`. If system cannot reach a shell, boot ISO first, mount target, then rebuild known-good flake revision. Do not rely on interactive systemd-boot menu in this Parallels configuration.

## Deliberate non-goals and risks

- This POC does not copy Omarchy code, branding, package scripts, or x86_64-only dependencies.
- It does not claim every Omarchy Quattro component has a NixOS equivalent.
- Quickshell development moves quickly. Keep custom QML narrow and validate in ARM guest before expanding it.
- Parallels VirtIO/VirGL is host-managed. `+virgl` proves acceleration exists; it does not imply OpenGL 4.3 or Ghostty compatibility.
- VM hardware changes require VM state `stopped`, not suspended. Always confirm with `prlctl list -a`.
- Current guest has no disk encryption or production backup policy. Add both only after desktop loop is stable.

## Incremental development plan

1. **Baseline:** host, Hyprland, portal/lock/idle plumbing, themed Quickshell panel, Kitty fallback, Parallels installation/recovery guide.
2. **Shell observability:** add focused Quickshell workspace indicator and tray; validate reload behavior.
3. **Interaction:** add Quickshell IPC and launcher/menu surface; preserve Fuzzel fallback until reliable.
4. **Service consolidation:** move notifications/media/network widgets into Quickshell only after each component matches fallback behavior.
5. **Host polish:** test clipboard, shared folders, resolution behavior after host resize, camera/microphone, suspend, and per-Mac display overrides without changing Darwin systems.
