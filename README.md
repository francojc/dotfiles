# DOTFILES

This repository contains my personal dotfiles for configuring my development environment on macOS.

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
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
   ```

4. **Bootstrap nix-darwin**:
   After installing Nix, you can bootstrap nix-darwin by running:

   ```bash
   nix build --impure --expr '<nix-darwin>' -o result
   ./result/bin/darwin-rebuild switch
   ```

## Restoring Dotfiles

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
   ```

2. Navigate to the dotfiles directory:

   ```bash
   cd ~/.dotfiles
   ```

3. Apply the configurations using the alias 'switch':

   ```bash
   switch
   ```

## Nix Configuration

My Zsh and Neovim configurations are managed declaratively using Nix. Please refer to the Nix documentation for more details on how to set up your environment.

## Backup Existing Configurations

Before applying the new configurations, it's a good idea to back up your existing dotfiles. You can do this by renaming them or moving them to a backup directory.
