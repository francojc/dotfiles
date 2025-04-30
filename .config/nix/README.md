# My Nix Darwin Configuration

<!--toc:start-->

- [My Nix Darwin Configuration](#my-nix-darwin-configuration)
 - [Configuration Structure](#configuration-structure)

<!--toc:end-->

> **Note**: This is a personal configuration, and it may not be suitable for you. You can use it as a reference to build your own configuration. I recommend taking a look a the "Nix Darwin Kickstarter" demo which served as a reference for this configuration.

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
│   │   │   ├── ai.lua
│   │   │   ├── colorscheme.lua
│   │   │   ├── completion.lua
│   │   │   ├── general.lua
│   │   │   ├── lsp.lua
│   │   │   ├── tools.lua
│   │   │   └── ui.lua
│   │   └── snippets
│   │       ├── all.json
│   │       ├── markdown.json
│   │       ├── nix.json
│   │       ├── package.json
│   │       ├── quarto.json
│   │       └── r.json
│   ├── shell
│   │   ├── aliases.zsh
│   │   ├── default.nix
│   │   └── fzf.zsh
│   └── vim.nix
├── Justfile
├── modules
│   ├── apps.nix
│   ├── host-users.nix
│   ├── nix-core.nix
│   └── system.nix
└── README.md
```
