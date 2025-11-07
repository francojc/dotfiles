# Neovim Configuration

A streamlined, modular Neovim configuration with lazy-loading support for optimal startup performance. Built on native Vim functionality where possible, with carefully selected plugins for enhanced productivity.

## Features

### Document Editing

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
- **File Management**: Snacks picker and Yazi file explorer
- **Terminal**: Integrated Snacks terminal with tmux navigation
- **Lazy-loading**: lz.n plugin for optimized startup performance

### Configuration Stats

- **Total Plugins**: 46 (including 10 colorschemes)
- **Eager-loaded**: 25 core plugins
- **Lazy-loaded**: 11 document/tool plugins
- **Philosophy**: Native Vim functionality preferred over plugin dependencies

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

- `<leader>ff` - Find files (Snacks picker)
- `<leader>fg` - Live grep search
- `<leader>fr` - Recent files
- `<leader>fn` - New file

### Buffer Management

- `<Tab>` / `<S-Tab>` - Navigate to next/previous buffer
- `<leader>bd` - Delete buffer
- `<leader>bf` - Find buffer (Snacks picker)

### Git Integration

- `<leader>gg` - Lazygit (lazy-loaded on command)
- `<leader>gd` - Diffview open
- `<leader>gh` - File history

### Markdown Editing

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

- `<leader>ta` - Toggle Aerial code outline (lazy-loaded on command)
- `<leader>ti` - Toggle image rendering
- `<leader>tm` - Toggle markdown rendering
- `<leader>tt` - Toggle floating terminal (Snacks)

## Plugin Management

This configuration uses [paq-nvim](https://github.com/savq/paq-nvim) for plugin installation and [lz.n](https://github.com/nvim-neorocks/lz.n) for lazy-loading. Plugins are automatically bootstrapped on first run.

### Main Plugins

**Core (Eager-loaded)**:

- **Completion**: blink.cmp with emoji and pandoc references
- **LSP**: nvim-lspconfig with multiple language servers
- **UI**: lualine, which-key
- **Navigation**: Snacks picker
- **Git**: gitsigns.nvim (lazy-loaded on file open)
- **Editing**: mini.nvim suite, copilot.vim, treesitter

**Documents (Lazy-loaded)**:

- **quarto-nvim, otter.nvim**: Loaded on `.qmd` files
- **obsidian.nvim**: Loaded on markdown files
- **render-markdown.nvim**: Loaded on markdown/quarto files
- **image.nvim, img-clip.nvim**: Loaded on markdown files

**Tools (Lazy-loaded)**:

- **lazygit.nvim**: Loaded on `:LazyGit` command
- **yazi.nvim**: Loaded on `:Yazi` command
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
- UI essentials (statusline)
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

### Step 2.5: Discovering Plugin Triggers

When adding a lazy-loaded plugin, you need to know what triggers to use (`cmd`, `ft`, `keys`, or `event`). Here's how to find them:

#### Finding Commands (`cmd`)

For plugins that load on commands (e.g., `:LazyGit`, `:Yazi`):

1. **Check the plugin's README/documentation**:
   - Look for a "Commands" or "Usage" section
   - Example: [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) lists `:LazyGit`, `:LazyGitLog`

2. **Check the plugin's help documentation**:

   ```vim
   :help plugin-name
   :help plugin-name-commands
   ```

3. **Browse the plugin's source code**:
   - Look in `plugin/*.vim` or `plugin/*.lua` files
   - Search for `vim.api.nvim_create_user_command` (Lua) or `command!` (Vimscript)
   - Example: In `aerial.nvim/plugin/aerial.lua`, you'll find `AerialToggle`, `AerialOpen`, etc.

4. **Load the plugin temporarily and list commands**:

   ```vim
   :packadd plugin-name
   :command
   ```
   Then search for commands related to the plugin (usually capitalized with the plugin name)

5. **Check GitHub Issues/Discussions**:
   - Other users often ask about available commands
   - The plugin author may have documented them in issue responses

#### Finding Filetypes (`ft`)

For plugins that load on specific filetypes:

1. **Check the plugin's documentation** for supported file types
2. **Identify the filetype** you want to trigger on:
   ```vim
   :set filetype?
   ```
   While editing the file type in question

3. **Common filetypes**:
   - `markdown`, `quarto`, `python`, `lua`, `r`, `csv`, `json`, `yaml`

#### Finding Keys (`keys`)

For plugins that should load on specific key mappings:

1. **Check the plugin's documentation** for default keybindings
2. **Decide which keys should trigger loading**:
   - If you want the plugin available when you press `<leader>sf`, add that to `keys`
3. **Specify the mode**:
   ```lua
   keys = {
     { "<leader>sf", mode = { "n", "x", "o" } },  -- normal, visual, operator-pending
   }
   ```

#### Finding Events (`event`)

For plugins that should load on Neovim events (autocmd triggers):

**When to use events:**

- Plugins that enhance editing but aren't needed immediately at startup
- Plugins that monitor file changes, cursor movement, or mode changes
- Plugins that provide functionality after files are loaded (e.g., git integration)

**How to discover which events to use:**

1. **Check the plugin's documentation**:

   - Look for "lazy-loading" or "performance" sections
   - Some plugins explicitly recommend events for lazy-loading
   - Example: Many git plugins recommend `BufReadPre` or `BufNewFile`

2. **Check the plugin's autocommands**:

   - Look in `plugin/*.lua` or `plugin/*.vim` for `vim.api.nvim_create_autocmd` or `autocmd`
   - The events they use internally are good candidates for lazy-loading triggers
   - Example: If a plugin sets up autocommands on `BufWritePost`, consider loading it on `BufReadPre`

3. **Examine similar plugin configurations**:

   - Check lazy.nvim or other dotfiles repositories
   - See what events others use for similar plugins
   - Example: Git plugins typically use `{ "BufReadPre", "BufNewFile" }`

4. **Test and observe**:

   - Load the plugin on a broad event (e.g., `BufReadPre`)
   - Check `:messages` to see when it actually activates
   - Refine to more specific events if needed

**Common event patterns:**

| Event(s)                     | When to Use                                                  | Example Plugins                 |
| ---------------------------- | ------------------------------------------------------------ | ------------------------------- |
| `BufReadPre`, `BufNewFile`   | File-related plugins that should load when opening any file  | gitsigns.nvim, file watchers    |
| `BufReadPost`                | Plugins that need the buffer content to be loaded            | Syntax/indent plugins           |
| `InsertEnter`                | Completion or snippet plugins (if not needed immediately)    | Alternative completion sources  |
| `CmdlineEnter`               | Command-line enhancement plugins                             | Command-line completion helpers |
| `VeryLazy`                   | Plugins that can wait until after startup is complete        | Non-essential UI enhancements   |
| `BufWritePre`, `BufWritePost`| Auto-formatting, linting, or save hooks                      | Formatters (if not using conform)|
| `VimEnter`                   | Plugins needed after Neovim fully initializes                | Dashboard plugins (use commands)|
| `FileType <type>`            | Same as `ft`, but more explicit                              | Use `ft` parameter instead      |

**View all available events:**

```vim
:help autocmd-events
```

**Example from this config:**

In `lua/plugins/editor.lua`, gitsigns uses events:

```lua
{
  "gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  after = function()
    require("gitsigns").setup()
  end,
}
```

This loads gitsigns when you open any file (before reading or when creating new), which is ideal because:

- It doesn't slow down startup (only loads when you open a file)
- It's available immediately when you need git information
- `BufReadPre` triggers before the buffer is displayed, so git signs appear instantly

**Tips:**

- Use multiple events with `event = { "Event1", "Event2" }` for flexibility
- Earlier events (like `BufReadPre`) are better for visual plugins to avoid flicker
- Later events (like `BufReadPost`) are fine for background processing
- Avoid `VimEnter` for lazy-loading (defeats the purpose)
- When in doubt, start with `BufReadPre` for file-related plugins

#### Example: Discovering lazygit.nvim Commands

1. Visit [https://github.com/kdheepak/lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)
2. Read the README - it lists:
   - `:LazyGit` - Open lazygit
   - `:LazyGitLog` - Open git log

3. Add to `lua/plugins/commands.lua`:
   ```lua
   {
     "lazygit.nvim",
     cmd = { "LazyGit", "LazyGitLog" },
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

### Document Settings

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

## Design Philosophy

This configuration emphasizes:

1. **Native First**: Use built-in Vim/Neovim functionality when possible (`:bnext/:bprevious` instead of buffer tabs)
2. **Plugin Efficiency**: Avoid duplicate functionality (Snacks.nvim for both terminal and picker)
3. **Lazy Loading**: Load plugins only when needed to optimize startup time
4. **Minimal UI**: Clean interface without startup screens or buffer tabs
5. **Productivity Focus**: Balance powerful features with simplicity and performance

Recent removals for streamlining:
- alpha-nvim (startup dashboard) → Direct file opening
- bufferline.nvim (buffer tabs) → Native buffer commands
- toggleterm.nvim (terminal manager) → Snacks terminal
- flash.nvim (enhanced navigation) → Native motions
- nvim-notify (notifications) → fidget.nvim integration
- nvim-web-devicons (icons) → mini.icons
- vim-markdown (markdown support) → render-markdown.nvim

## License

This configuration is provided as-is.
