# Neovim Configuration

A comprehensive Neovim configuration tailored for academic writing and computational linguistics research.

## Features

### Academic Writing Focus
- **Quarto Integration**: Full support for Quarto documents with code execution
- **Markdown Enhancement**: Custom keybindings for formatting, lists, and headers
- **Obsidian Integration**: Note-taking and knowledge management
- **Citation Management**: Pandoc references with completion support
- **Image Handling**: Paste and render images directly in documents

### Language Support
- **R**: Language server with code execution via Slime
- **Python**: Pyright LSP with Ruff formatting
- **Bash**: Full LSP support with shfmt formatting
- **Lua**: Native Neovim configuration language support
- **Nix**: NixOS/Home Manager integration with nixd LSP
- **YAML**: Quarto schema validation

### Modern Development Tools
- **LSP**: Comprehensive language server protocol support
- **Completion**: Blink.cmp with emoji and reference completion
- **Git Integration**: Lazygit, Gitsigns, and Diffview
- **File Management**: FZF fuzzy finding and Yazi file explorer
- **Terminal**: Integrated toggleterm with tmux navigation

## Installation

### Prerequisites
- Neovim >= 0.9.0
- Git
- Node.js (for some LSP servers)
- Required formatters and language servers (installed automatically via LSP)

### Setup
1. Clone or symlink this configuration to your Neovim config directory:
   ```bash
   # If part of a dotfiles setup
   ln -sf ~/.dotfiles/.config/nvim ~/.config/nvim
   ```

2. Start Neovim - plugins will be installed automatically via paq-nvim bootstrap

3. Run `:PaqInstall` to ensure all plugins are installed

## Key Bindings

### Leader Key
- Space (` `) is the leader key

### File Operations
- `<leader>ff` - Find files (FZF)
- `<leader>fg` - Live grep search
- `<leader>fr` - Recent files
- `<leader>fn` - New file

### Buffer Management
- `<Tab>` / `<S-Tab>` - Cycle through buffers
- `<leader>bd` - Delete buffer
- `<leader>bo` - Close other buffers

### Git Integration
- `<leader>gg` - Lazygit
- `<leader>gd` - Diffview open
- `<leader>gh` - File history

### Academic Writing
- `<leader>m1-4` - Insert markdown headings
- `<leader>mu` - Unordered list item
- `<leader>mo` - Ordered list item
- `<leader>mt` - Task list item
- `<leader>mb/mi/ms` - Bold/italic/strikethrough text
- `<leader>mp` - Paste image

### Code Execution (Quarto/R)
- `<C-CR>` - Send current cell
- `<leader>qa` - Send above
- `<leader>qb` - Send below
- `<leader>qf` - Send entire file

### Obsidian
- `<leader>on` - New note
- `<leader>od` - Daily note
- `<leader>of` - Follow link
- `<leader>oc` - Toggle checkbox

## Plugin Management

This configuration uses [paq-nvim](https://github.com/savq/paq-nvim) for plugin management. Plugins are automatically bootstrapped on first run.

### Main Plugins
- **Completion**: blink.cmp with emoji and pandoc references
- **LSP**: nvim-lspconfig with multiple language servers
- **Git**: lazygit.nvim, gitsigns.nvim, diffview.nvim
- **File Explorer**: yazi.nvim, fzf-lua
- **Academic**: quarto-nvim, obsidian.nvim, render-markdown.nvim
- **Themes**: Multiple colorschemes (Vague, Gruvbox, OneDark, etc.)

## Configuration Structure

```
.
├── init.lua              # Main configuration file
├── lua/
│   ├── bootstrap.lua     # Plugin manager bootstrap
│   └── theme-config.lua  # Theme configuration
├── ftplugins/            # Filetype-specific settings
├── snippets/             # Custom snippets
└── README.md            # This file
```

## Customization

### Themes
Current theme is set in `lua/theme-config.lua`. Available themes:
- Vague (default)
- Gruvbox
- OneDark
- Nightfox
- Arthur
- Autumn
- Black Metal

### Language Servers
LSP configurations are in `init.lua` starting at line 929. Modify as needed for your development environment.

### Academic Settings
Quarto and R integration settings can be found in the respective plugin configurations. Obsidian workspace paths may need adjustment for your setup.

## Troubleshooting

### Plugin Issues
- Run `:PaqClean` then `:PaqInstall` to refresh plugins
- Check `:checkhealth` for system dependencies

### LSP Issues
- Ensure language servers are installed system-wide
- Check `:LspInfo` for active language servers
- Use `<leader>tr` to toggle R language server

### Performance
- Image rendering can be toggled with `<leader>ti`
- Disable unused plugins in the paq configuration section

## License

This configuration is provided as-is for educational and research purposes.