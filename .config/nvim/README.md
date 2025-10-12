# Neovim Configuration

A comprehensive, modular Neovim configuration tailored for academic writing and computational linguistics research, with lazy-loading support for optimal startup performance.

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
- **Lazy-loading**: lz.n plugin for optimized startup performance

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

3. Run `:PaqInstall` to ensure all plugins are installed (including lazy-loaded ones in `opt` directory)

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

- `<leader>gg` - Lazygit (lazy-loaded on command)
- `<leader>gd` - Diffview open
- `<leader>gh` - File history

### Academic Writing

- `<leader>m1-4` - Insert markdown headings
- `<leader>mu` - Unordered list item
- `<leader>mo` - Ordered list item
- `<leader>mt` - Task list item
- `<leader>mb/mi/ms` - Bold/italic/strikethrough text
- `<leader>mp` - Paste image (lazy-loaded on markdown/quarto files)

### Code Execution (Quarto/R)

- `<C-CR>` - Send current cell
- `<leader>qa` - Send above
- `<leader>qb` - Send below
- `<leader>qf` - Send entire file

### Obsidian

- `<leader>on` - New note (lazy-loaded on markdown files)
- `<leader>od` - Daily note
- `<leader>of` - Follow link
- `<leader>oc` - Toggle checkbox

### File Explorer

- `<leader>ey` - Open Yazi (lazy-loaded on command)
- `<leader>ec` - Open Yazi in cwd

### Toggles

- `<leader>ta` - Toggle Aerial (lazy-loaded on command)
- `<leader>ti` - Toggle image rendering
- `<leader>tm` - Toggle markdown rendering
- `<leader>tt` - Toggle terminal (lazy-loaded on command)

## Plugin Management

This configuration uses [paq-nvim](https://github.com/savq/paq-nvim) for plugin installation and [lz.n](https://github.com/nvim-neorocks/lz.n) for lazy-loading. Plugins are automatically bootstrapped on first run.

### Main Plugins

**Core (Eager-loaded)**:

- **Completion**: blink.cmp with emoji and pandoc references
- **LSP**: nvim-lspconfig with multiple language servers
- **UI**: lualine, bufferline, which-key, alpha-nvim
- **Navigation**: fzf-lua, flash.nvim
- **Git**: gitsigns.nvim (lazy-loaded on file open)
- **Editing**: mini.nvim suite, copilot.vim, treesitter

**Academic (Lazy-loaded)**:

- **quarto-nvim, otter.nvim**: Loaded on `.qmd` files
- **obsidian.nvim**: Loaded on markdown files
- **render-markdown.nvim**: Loaded on markdown/quarto files
- **image.nvim, img-clip.nvim**: Loaded on markdown files

**Tools (Lazy-loaded)**:

- **lazygit.nvim**: Loaded on `:LazyGit` command
- **yazi.nvim**: Loaded on `:Yazi` command
- **toggleterm.nvim**: Loaded on `:ToggleTerm` command
- **aerial.nvim**: Loaded on `:AerialToggle` command
- **todo-comments.nvim**: Loaded on search commands

## Configuration Structure

```
.
├── init.lua                      # Main orchestrator (loads modules)
├── lua/
│   ├── bootstrap.lua             # Paq-nvim bootstrap
│   ├── theme-config.lua          # Theme configuration (Nix-managed)
│   ├── sidekick-highlights.lua   # Custom highlight groups
│   ├── plugins-paq.lua           # Paq plugin declarations
│   ├── plugins-config.lua        # Eager-loaded plugin configs
│   ├── core/
│   │   ├── options.lua           # Vim options & diagnostics
│   │   ├── autocommands.lua      # Autocommands & autocmds
│   │   ├── keymaps.lua           # All key mappings
│   │   └── functions.lua         # Helper functions
│   └── plugins/
│       ├── commands.lua          # Lazy-load on commands
│       ├── editor.lua            # Lazy-load on keys/events
│       └── filetype.lua          # Lazy-load on filetypes
├── ftplugins/                    # Filetype-specific settings
│   ├── markdown.lua
│   └── quarto.lua
└── README.md                     # This file
```

### Module Responsibilities

- **`init.lua`**: Orchestrates loading of all modules in correct order
- **`plugins-paq.lua`**: Declares all plugins with paq (marks lazy ones with `opt = true`)
- **`plugins-config.lua`**: Configures eager-loaded plugins
- **`lua/plugins/*.lua`**: lz.n lazy-loading specs (auto-discovered)
- **`lua/core/*.lua`**: Core Neovim settings (options, keymaps, autocommands, functions)

## Adding New Plugins

### Step 1: Declare the Plugin in `lua/plugins-paq.lua`

Add the plugin to the paq declaration:

```lua
require("paq")({
  -- Existing plugins...

  -- Add your plugin:
  "author/plugin-name", -- For eager-loading
  -- OR
  { "author/plugin-name", opt = true }, -- For lazy-loading
})
```

**When to use `opt = true`**:

- Plugin is only needed for specific filetypes (e.g., markdown, quarto)
- Plugin is accessed via commands (e.g., `:LazyGit`)
- Plugin is triggered by specific keys
- Plugin is not essential for startup

**Keep eager-loaded if**:

- Core editing functionality (LSP, completion, treesitter)
- UI essentials (statusline, bufferline)
- Used immediately on startup

### Step 2: Choose Configuration Location

#### For Eager-loaded Plugins

Add configuration to **`lua/plugins-config.lua`**:

```lua
---| Your Plugin Name ----------------------------------
require("your-plugin").setup({
  -- Configuration here
})
```

Place it in alphabetical order among other plugins.

#### For Lazy-loaded Plugins

Add configuration to the appropriate spec file in **`lua/plugins/`**:

**`lua/plugins/commands.lua`** - Load on command:

```lua
{
  "plugin-name",
  cmd = { "CommandName", "OtherCommand" },
  after = function()
    require("plugin").setup({
      -- Configuration here
    })
  end,
}
```


**`lua/plugins/filetype.lua`** - Load on filetype:

```lua
{
  "plugin-name",
  ft = { "markdown", "quarto" },
  after = function()
    require("plugin").setup({
      -- Configuration here
    })
  end,
}
```

**`lua/plugins/editor.lua`** - Load on keys or events:

```lua
{
  "plugin-name",
  keys = {
    { "<leader>key", mode = { "n", "v" } },
  },
  -- OR
  event = { "BufReadPre", "BufNewFile" },
  after = function()
    require("plugin").setup({
      -- Configuration here
    })
  end,
}
```

### Step 3: Add Keybindings (if needed)

Add keybindings to **`lua/core/keymaps.lua`**:

```lua
-- For eager-loaded plugins
map("n", "<leader>key", "<Cmd>PluginCommand<Cr>", { desc = "Description" })

-- For lazy-loaded plugins (triggers will load the plugin)
map("n", "<leader>key", "<Cmd>PluginCommand<Cr>", { desc = "Description" })
```

### Step 4: Install the Plugin

```vim
:PaqInstall
```

Restart Neovim to load the configuration.

### Example: Adding a New Plugin

Let's say you want to add `neovim/nvim-lspconfig`:

1. **Declare** in `lua/plugins-paq.lua`:
   ```lua
   "neovim/nvim-lspconfig", -- Eager-load (needed immediately)
   ```

2. **Configure** in `lua/plugins-config.lua`:
   ```lua
   ---| LSP Config ----------------------------------
   require("lspconfig").rust_analyzer.setup({
     capabilities = capabilities, -- From blink.cmp
   })
   ```

3. **No keybindings needed** (LSP uses built-in mappings)

4. **Install**: `:PaqInstall`

### Example: Adding a Lazy-loaded Plugin

Let's say you want to add a PDF viewer that loads on `.pdf` files:

1. **Declare** in `lua/plugins-paq.lua`:
   ```lua
   { "author/pdf-viewer.nvim", opt = true }, -- Lazy-load
   ```

2. **Configure** in `lua/plugins/filetype.lua`:
   ```lua
   {
     "pdf-viewer.nvim",
     ft = "pdf",
     after = function()
       require("pdf-viewer").setup({
         zoom = 1.5,
       })
     end,
   }
   ```

3. **Add keybinding** in `lua/core/keymaps.lua`:
   ```lua
   map("n", "<leader>pz", "<Cmd>PdfZoom<Cr>", { desc = "PDF Zoom" })
   ```

4. **Install**: `:PaqInstall`

## Customization

### Themes

Current theme is set in `lua/theme-config.lua` (Nix-managed). Available themes:
- Gruvbox (default)
- Vague
- OneDark
- Nightfox
- Arthur
- Autumn
- Black Metal

### Language Servers

LSP configurations are in `lua/plugins-config.lua`. Modify as needed for your development environment. LSP capabilities are defined early in the file and used by all language server configs.

### Academic Settings

Quarto and R integration settings can be found in `lua/plugins/filetype.lua`. Obsidian workspace paths may need adjustment for your setup in the same file.

### Core Settings

- **Options**: `lua/core/options.lua`
- **Keymaps**: `lua/core/keymaps.lua`
- **Autocommands**: `lua/core/autocommands.lua`
- **Helper Functions**: `lua/core/functions.lua`

## Troubleshooting

### Plugin Issues

- Run `:PaqClean` then `:PaqInstall` to refresh plugins
- Check `:checkhealth` for system dependencies
- Ensure lazy-loaded plugins are in `~/.local/share/nvim/site/pack/paqs/opt/`
- Ensure eager-loaded plugins are in `~/.local/share/nvim/site/pack/paqs/start/`

### Lazy-loading Issues

- Check loaded plugins: `:lua print(vim.inspect(require("lz.n").loaded))`
- Verify plugin specs: `:lua print(vim.inspect(require("lz.n").specs))`
- Check for errors: `:messages`

### LSP Issues

- Ensure language servers are installed system-wide
- Check `:LspInfo` for active language servers
- Use `<leader>tr` to toggle R language server

### Performance

- Image rendering can be toggled with `<leader>ti`
- Check startup time: `nvim --startuptime startup.log`
- Most plugins are lazy-loaded for optimal performance
- Disable unused plugins in `lua/plugins-paq.lua`

## License

This configuration is provided as-is for educational and research purposes.
