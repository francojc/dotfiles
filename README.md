# DOTFILES

This repository contains my personal dotfiles for configuring my development environment on MacOS/ NixOS.

> [!NOTE]
> Before applying the new configurations, it's a good idea to back up your existing dotfiles. You can do this by renaming them or moving them to a backup directory.

# MacOS

## Prerequisites

Before restoring the dotfiles, ensure you have the following installed:

1. **Install Xcode Command Line Tools**:
   Open your terminal and run:

   ```bash
   xcode-select --install
   ```

2. **Install Homebrew**:
   Run the following command in your terminal:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **Install Nix**:
   Use the following command to install Nix using the Determinate Systems installer for macOS (multi-user install):

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
   Check that your installation was successful by running:

   ```bash
   nix --version
   ```

4. **Bootstrap nix-darwin**:
   After installing Nix, you can bootstrap nix-darwin by running the following commands:

   ```bash
   mkdir -p ~/.config/nix/
   cd ~/.config/nix/
   nix  flake init -t nix-darwin
   sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix
   ```

   You will then need to add `nix.enable = false;` to the `~/.config/nix/flake.nix` file to allow nix-darwin to manage the Nix configuration.

   After that, you can run the following command to install nix-darwin:

   ```bash
   sudo nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/nix
   ```

   Check to see that the installation was successful by running:

   ```bash
   type darwin-rebuild
   ```

## Restoring Dotfiles

1. Clone the repository:

   ```bash
   git clone --depth 1 https://github.com/francojc/dotfiles.git ~/.dotfiles
   ```

2. Navigate to the dotfiles directory:

   ```bash
   cd ~/.dotfiles
   ```

3. Remove any existing files that may conflict with the configurations:

   ```bash
   rm -rf ~/.zshrc ~/.zshenv ~/.zsh ~/.config/nix
   ```

4. Make sure the `flake.nix` hostname to match the system hostname:

   To find the hostname, run the following command:

   ```bash
   hostname
   ```

   > [!NOTE]
   > You can update the hostname in macOS running `sudo scutil --set LocalHostName <new-hostname>`. I've also found that running `sudo hostname -s <new-hostname>` can help in some cases.

5. Apply the configurations using the full path to the flake's directory:

   <!-- WARN: the NIXPKGS_ALLOW_UNFREE=1 is a temporary workaround to allow the installation of unfree packages. -->

   ```bash
   NIXPKGS_ALLOW_UNFREE=1 darwin-rebuild switch --flake ~/.dotfiles/.config/nix/#<yourhostname> --impure
   ```

   _Note:_ After a successful switch, you will be able to use the alias `switch` to apply the configurations in the future.

5. Use `stow` to symlink the configurations:

   ```bash
   cd ~/.dotfiles
   stow .
   ```

# NixOS

This repository supports NixOS systems with two pre-configured host examples and a flexible module system that mirrors the macOS setup.

## Available Host Configurations

This dotfiles repository includes two NixOS host examples with different desktop environments:

### `nixos` Host (Modern Wayland Setup)

- **Desktop Environment**: Sway (Wayland compositor)
- **Applications**: GNOME ecosystem, Flatpak integration
- **Features**: Modern Wayland workflow, touchpad-friendly
- **Best for**: Laptops, modern hardware, Wayland-compatible workflows

### `minirover` Host (Traditional X11 Setup)

- **Desktop Environment**: i3 (X11 window manager)
- **Applications**: Traditional Linux desktop applications
- **Features**: XRDP remote desktop support, X11 compatibility
- **Best for**: Servers, older hardware, remote access scenarios

## Prerequisites

Before setting up the NixOS configuration, ensure you have the following:

1. **NixOS Installation**: A working NixOS system (minimal installation is sufficient)

2. **Flakes Support**: Enable experimental features by adding to `/etc/nixos/configuration.nix`:

   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```

   Then rebuild: `sudo nixos-rebuild switch`

3. **Git**: Install Git if not already available:

   ```bash
   nix-shell -p git
   ```

## Installation Process

1. **Clone the repository**:

   ```bash
   git clone --depth 1 https://github.com/francojc/dotfiles.git ~/.dotfiles
   ```

2. **Navigate to the dotfiles directory**:

   ```bash
   cd ~/.dotfiles
   ```

3. **Choose your host configuration approach**:

   You can either use one of the existing host configurations or create a new one.

### Option A: Use Existing Host Configuration

4a. **Review available configurations**:

   - For modern Wayland setup: Use `nixos` host configuration
   - For traditional X11 setup: Use `minirover` host configuration

5a. **Update host configuration** (optional):

   Edit `.config/nix/hosts/nixos/default.nix` (or `minirover`) to customize:

   ```bash
   nano .config/nix/hosts/nixos/default.nix
   ```

   Update the username and email:

   ```nix
   username = "yourusername";
   useremail = "your.email@example.com";
   ```

### Option B: Create New Host Configuration

4b. **Generate hardware configuration**:

   ```bash
   sudo nixos-generate-config --show-hardware-config > .config/nix/hosts/$(hostname)/hardware-configuration.nix
   ```

5b. **Create host directory and configuration**:

   ```bash
   mkdir -p .config/nix/hosts/$(hostname)
   ```

   Create `.config/nix/hosts/$(hostname)/default.nix` based on one of the existing examples.

6b. **Update the flake.nix**:

   Add your hostname to the hosts configuration in `.config/nix/flake.nix`:

   ```nix
   hosts = {
     "Macbook-Airborne" = import ./hosts/Macbook-Airborne/default.nix;
     "Mac-Minicore" = import ./hosts/Mac-Minicore/default.nix;
     "minirover" = import ./hosts/minirover/default.nix;
     "yourhostname" = import ./hosts/yourhostname/default.nix;  # Add this line
   };
   ```

## Apply Configuration

6. **Build and apply the NixOS configuration**:

   ```bash
   sudo nixos-rebuild switch --flake ~/.dotfiles/.config/nix/#yourhostname
   ```

   Replace `yourhostname` with:
   - `nixos` for the Sway/Wayland setup
   - `minirover` for the i3/X11 setup
   - Your custom hostname if you created a new configuration

   > [!NOTE]
   > The first build may take longer as it downloads and builds all required packages.

7. **Apply dotfiles symlinks**:

   ```bash
   cd ~/.dotfiles
   stow .
   ```

## Post-Installation

### Desktop Environment Setup

**For Sway (nixos host)**:

- Sway will be available in your display manager
- Waybar and Wofi are pre-configured
- GNOME applications and extensions are included

**For i3 (minirover host)**:

- i3 will be available in your display manager
- XRDP is configured for remote desktop access
- Traditional X11 applications are prioritized

### Application Management

**NixOS uses Flatpak** instead of Homebrew for GUI applications:

- Flatpak is automatically configured and enabled
- Pre-configured remotes include Flathub and Flathub Beta
- Applications are managed through the nix configuration in `modules/nixos/apps.nix`

### Customization

**Theme Configuration**:

The system uses the theme specified in your host configuration. Available themes:

- `gruvbox` (default)
- `nightfox`
- `arthur`
- `onedark`

**Adding Packages**:

- System packages: Edit `modules/nixos/apps.nix`
- User packages: Edit appropriate files in `home/`
- Flatpak packages: Add to the packages list in `modules/nixos/apps.nix`

### Future Updates

To update your system configuration:

```bash
cd ~/.dotfiles
git pull
sudo nixos-rebuild switch --flake .config/nix/#yourhostname
```

To update packages:

```bash
cd ~/.dotfiles/.config/nix
nix flake update
sudo nixos-rebuild switch --flake ./#yourhostname
```

## Troubleshooting

**Configuration fails to build**:

- Check that your hostname matches the configuration name exactly
- Verify that hardware-configuration.nix exists and is properly formatted
- Ensure experimental features are enabled

**Missing hardware-configuration.nix**:

```bash
sudo nixos-generate-config --show-hardware-config > .config/nix/hosts/yourhostname/hardware-configuration.nix
```

**Permission issues**:

Ensure you're using `sudo` for nixos-rebuild commands and your user is in the `wheel` group.

## Key Differences from macOS Setup

- **Package Management**: Flatpak replaces Homebrew for GUI applications
- **Window Managers**: Sway (Wayland) or i3 (X11) instead of macOS window management
- **Home Directory**: `/home/username` instead of `/Users/username`
- **Build Command**: `nixos-rebuild switch` instead of `darwin-rebuild switch`
- **Modules**: Uses `nixosModules` instead of `darwinModules`
