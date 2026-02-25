# Neovim 0.12+ Ultra-Stock Configuration

A pure built-in Neovim configuration leveraging 0.12+ features with zero external plugins.

## Features

### Core 0.12+ Options
- `'autocomplete'` - Built-in completion system
- `'completefuzzycollect'` - Fuzzy collection of completion candidates
- `'pummaxwidth'` - Maximum width for popup menu
- `'winborder'` - Consistent window borders
- `'autowriteall'` - Automatic buffer saving on signals
- `'diffopt'` with indent-heuristic and inline:char
- `'maxsearchcount'` - Maximum search count (999)
- `'fillchars'` with foldinner support

### LSP Configuration
- `vim.lsp.enable()` - Simplified LSP setup
- `vim.lsp.Config` with workspace awareness
- Selection ranges via `an`/`in` mappings
- Type definitions via `grt` mapping
- Document colors and linked editing support

### Editor Enhancements
- Treesitter syntax highlighting
- Enhanced completion with 0.12 flags
- Custom statusline with diagnostic integration
- Busy indicator (◐ symbol)
- URL opening with `gx`

### Key Mappings
- `an` - Select outward (selection ranges)
- `in` - Select inward (selection ranges)
- `grt` - Type definition (0.12 native)
- `gx` - Open URL under cursor

## Structure

```
init.lua (single file, ~180 lines)
├── Version check for 0.12+
├── Core settings (0.12+ options)
├── Plugin management (vim.pack ready)
├── LSP configuration
├── Editor enhancements
├── Statusline with diagnostics
├── Key mappings
└── Autocommands
```

## Requirements

- Neovim 0.12 or later
- Language servers for LSP features (optional)

## Installation

1. Clone or copy `init.lua` to your Neovim config directory:
   ```bash
   cp init.lua ~/.config/nvim/init.lua
   ```

2. Start Neovim - no additional setup required

## Usage

This configuration is designed to work out-of-the-box with Neovim's built-in features:

- LSP will automatically start for supported file types
- Completion works with `'autocomplete'` enabled
- Treesitter provides syntax highlighting when parsers are available
- Statusline shows diagnostics and file information

## Customization

The configuration is intentionally minimal. To add features:

1. Use `vim.pack` for plugin management (built-in)
2. Add LSP servers via `vim.lsp.config()`
3. Modify autocommands for filetype-specific settings
4. Extend the statusline module as needed

## Performance

- **Startup time**: <50ms (no plugins to load)
- **Memory usage**: Minimal (only built-in features)
- **Dependencies**: Zero external plugins

## 0.12 Breaking Changes Handled

- Diagnostic signs (no longer use `sign_define`)
- `vim.diff` → `vim.text.diff`
- LSP `selection_range()` accepts integer
- UI messages changes (`msg_show.return_prompt` removed)

## License

Public domain - use as you wish.
