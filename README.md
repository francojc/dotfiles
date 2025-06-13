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

...
