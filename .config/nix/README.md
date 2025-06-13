# My Nix Darwin/ NixOS Configuration

<!--toc:start-->

- [My Nix Darwin Configuration](#my-nix-darwin-configuration)
 - [Configuration Structure](#configuration-structure)

<!--toc:end-->

> **Note**: This is a personal configuration, and it may not be suitable for you. You can use it as a reference to build your own configuration. 

## Configuration Structure

```txt
├── flake.lock
├── flake.nix
├── home
│   ├── core.nix
│   ├── default.nix
│   ├── git.nix
│   ├── neovim
│   │   ├── default.nix
│   │   ├── init.lua
│   │   ├── plugin
│   │   └── snippets
│   ├── shell
│   │   ├── aliases.zsh
│   │   ├── default.nix
│   │   └── fzf.zsh
│   └── vim.nix
├── hosts
│   ├── darwin
│   │   └── configuration.nix
│   └── nixos
│       ├── configuration.nix
│       ├── dconf.nix
│       ├── dconf.settings
│       └── hardware-configuration.nix
├── Justfile
├── modules
│   ├── darwin
│   │   └── apps.nix
│   ├── nixos
│   │   └── apps.nix
│   └── shared
│       ├── fonts.nix
│       ├── nix-core.nix
│       └── packages.nix
└── README.md
```
