# DOTFILES

This repository contains my dotfiles for macOS. I use [GNU Stow](https://www.gnu.org/software/stow/) to manage them. Secrets are stored in a separate repository using GPG and `pass`.

The `.backup` script is used to backup the current configurations and dotfiles. The `.restore` script is used to restore the backup.

## Installation

1. Install Xcode Command Line Tools:

```sh
xcode-select --install
```

2. Clone this repository:

```sh
git clone https://github.com/francojc/dotfiles.git ~/.dotfiles
```

3. Run the installation script:

```sh
~/.dotfiles/.restore
```
