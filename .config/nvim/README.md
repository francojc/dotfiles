# Neovim Configuration

A streamlined, modular Neovim configuration built on Neovim 0.12+ native functionality. Built on native Vim functionality where possible, with carefully selected plugins for enhanced productivity.


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
- **Go**: gopls and golangci-lint-langserver
- **Lua**: Native Neovim configuration language support
- **Nix**: NixOS/Home Manager integration with nixd LSP
- **Typst**: tinymist LSP with preview
- **YAML**: Quarto schema validation

### Modern Development Tools

- **LSP**: Comprehensive language server protocol support
- **Completion**: Blink.cmp with emoji and reference completion
- **Git Integration**: Lazygit, Gitsigns, and Diffview
- **File Management**: Snacks picker and Yazi file explorer
- **Terminal**: Integrated Snacks terminal with tmux navigation
- **GitHub Integration**: Issue/PR management via Snacks picker

### Configuration Stats

- **Total Plugins**: 44 (including 11 colorschemes)
- **Plugin Manager**: Neovim 0.12+ native vim.pack
- **Philosophy**: Native Vim functionality preferred over plugin dependencies

## Installation

### Prerequisites

- Neovim >= 0.12+
- Git
- Node.js (for some LSP servers)
- Required formatters and language servers (installed automatically via LSP)

### Setup

1. Clone, symlink, or `stow` this configuration to your Neovim config directory.

2. Start Neovim - plugins will be installed automatically via vim.pack

The first launch may take a moment as vim.pack downloads plugins in parallel

### Updating

Plugin management commands:

```vim
:PackUpdate        -- Update all plugins
:PackUpdate!       -- Force update all plugins
:PackUpdatePlugin  -- Update specific plugin (with picker if no name given)
:PackCheck         -- Check for available updates (groups by major/minor/patch)
:PackStatus        -- Show plugin status
:PackClean         -- Remove unused plugins
:PackSync          -- Install + update + clean
```

Weekly update checks are performed automatically on startup.

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

- `<leader>gg` - Lazygit
- `<leader>gl` - Lazygit log
- `<leader>gio` - GitHub issues (open)
- `<leader>gpo` - GitHub PRs (open)
- `<leader>gic` - Create GitHub issue
- `<leader>gpc` - Create GitHub PR (draft, base=main)
- `<leader>gpC` - Create GitHub PR (prompt)

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

- `<leader>ey` - Open Yazi
- `<leader>ec` - Open Yazi in cwd

### Session Management

- `<leader>ps` - Save session (prompts for name)
- `<leader>pl` - Load last session
- `<leader>pS` - Select session

### Toggles

- `<leader>ta` - Toggle Aerial code outline
- `<leader>tb` - Toggle line blame
- `<leader>tc` - Toggle color highlights
- `<leader>td` - Toggle word diff
- `<leader>ti` - Toggle image rendering
- `<leader>tl` - Select spell language (en_us/es)
- `<leader>tm` - Toggle markdown rendering
- `<leader>tr` - Toggle R language server
- `<leader>tR` - Toggle citation format (Pandoc/LaTeX)
- `<leader>ts` - Toggle spell
- `<leader>tv` - Toggle CSV view
- `<leader>tw` - Toggle word wrap

### Spell Language Management

The configuration automatically detects project-specific spell settings:

- Create `.nvim_spell_lang` in your project root with content `en_us` or `es`
- Use `<leader>tl` to interactively change spell language for current project
- Spell language persists per project directory

### Session Management

Sessions are automatically saved on exit to `~/.local/state/nvim/sessions/last.vim`. Manual session management available via `<leader>p*` keybindings.

## Plugin Management

This configuration uses Neovim 0.12+ native **vim.pack** for plugin installation and management. All plugins are eagerly loaded for immediate availability. Plugins are automatically installed on first run.

### Main Plugins

**Core Functionality**:

- **Completion**: blink.cmp with emoji and pandoc references
- **LSP**: Native vim.lsp with multiple language servers
- **UI**: which-key, theme-adaptive statusline
- **Navigation**: Snacks picker
- **Git**: gitsigns.nvim, lazygit.nvim
- **Editing**: mini.nvim suite (icons, pairs, surround), copilot.vim, treesitter
- **Formatting**: conform.nvim

**Documents & Markup**:

- **quarto-nvim, otter.nvim**: Quarto document support
- **obsidian.nvim**: Note-taking and knowledge management
- **render-markdown.nvim**: Markdown rendering enhancement
- **image.nvim, img-clip.nvim**: Image handling in documents
- **snacks-bibtex.nvim**: Citation management

**Development Tools**:

- **yazi.nvim**: File explorer
- **aerial.nvim**: Code outline
- **csvview.nvim**: CSV file viewing
- **typst-preview.nvim**: Typst document preview
- **quicker.nvim**: Quickfix list enhancement

## Configuration Structure

```
.
├── init.lua                      # Main orchestrator (loads modules)
├── lua/
│   ├── theme-config.lua          # Theme configuration (Nix-managed symlink)
│   ├── statusline-highlights.lua # Theme-adaptive statusline highlights
│   ├── plugins-pack.lua          # vim.pack plugin declarations
│   ├── plugins-config.lua        # Plugin configurations
│   ├── core/
│   │   ├── options.lua           # Vim options & diagnostics
│   │   ├── autocommands.lua      # Autocommands & user commands
│   │   ├── keymaps.lua           # All key mappings
│   │   └── functions.lua         # Helper functions (session, git, plugin mgmt)
│   └── plugins/                  # Plugin lazy-loading configs (not currently used)
├── after/
│   └── ftplugin/                # Filetype-specific settings
│       ├── markdown.lua
│       └── quarto.lua
└── README.md                     # This file
```

### Module Responsibilities

- **`init.lua`**: Orchestrates loading of all modules, Llama.vim configuration
- **`plugins-pack.lua`**: Declares all plugins with vim.pack (all eager-loaded)
- **`plugins-config.lua`**: Configures all plugins and LSP servers
- **`lua/core/functions.lua`**: Helper functions for sessions, plugin management, git branch caching, search count caching, toggle functions
- **`lua/core/autocommands.lua`**: Autocommands for git branch/search count updates, spell language, session auto-save, plugin update checks
- **`lua/core/keymaps.lua`**: All key mappings including new session, spell, GitHub bindings
- **`lua/statusline-highlights.lua`**: Theme-adaptive highlight groups for custom statusline
- **`after/ftplugin/*.lua`**: Filetype-specific configurations

## Adding New Plugins

### Step 1: Declare the Plugin in `lua/plugins-pack.lua`

Add the plugin to the vim.pack declaration array:

```lua
local eager_plugins = {
  -- Existing plugins...

  -- Add your plugin:
  { src = "https://github.com/author/plugin-name" },
}

vim.pack.add(eager_plugins, { load = true, confirm = false })
```

### Step 2: Configure the Plugin

Add configuration to **`lua/plugins-config.lua`**:

```lua
---| Your Plugin Name ----------------------------------
require("your-plugin").setup({
  -- Configuration here
})
```

Place it in the appropriate section based on functionality:
- Completion & snippets
- Colorschemes & theming
- Code formatting
- Language servers (LSP)
- Editor enhancements
- Syntax & parsing
- UI & navigation
- References & citations

### Step 3: Add Keybindings (if needed)

Add keybindings to **`lua/core/keymaps.lua`**:

```lua
-- Using the map() helper function
map("n", "<leader>key", "<Cmd>PluginCommand<Cr>", { desc = "Description" })
```

### Step 4: Install the Plugin

Restart Neovim. Plugins are automatically installed on first run.

To manually trigger installation:

```vim
:PackSync
```

### Example: Adding a New LSP Server

Let's say you want to add support for TypeScript:

1. **Configure LSP** in `lua/plugins-config.lua`:
   ```lua
   ---| TypeScript Development ----------------------------------
   vim.lsp.config.ts_ls = {
     capabilities = capabilities,
     filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
   }
   ```

2. **Auto-enable by filetype** (update the FileType autocmd):
   ```lua
   -- Add to the filetype list in plugins-config.lua
   "typescript",
   "typescriptreact",
   "javascript",
   "javascriptreact",

   -- Add to the server_map
   typescript = "ts_ls",
   typescriptreact = "ts_ls",
   javascript = "ts_ls",
   javascriptreact = "ts_ls",
   ```

### Example: Adding a New Plugin with Keybindings

Let's say you want to add a test runner plugin:

1. **Declare** in `lua/plugins-pack.lua`:
   ```lua
   { src = "https://github.com/author/test-runner.nvim" },
   ```

2. **Configure** in `lua/plugins-config.lua`:
   ```lua
   ---| Test Runner ----------------------------------
   require("test-runner").setup({
     adapters = { "jest", "pytest" },
   })
   ```

3. **Add keybindings** in `lua/core/keymaps.lua`:
   ```lua
   map("n", "<leader>tt", "<Cmd>TestRun<Cr>", { desc = "Run nearest test" })
   map("n", "<leader>tf", "<Cmd>TestFile<Cr>", { desc = "Run test file" })
   ```

4. **Restart Neovim** to install the plugin automatically.

## Customization

### Themes

Current theme is set in `lua/theme-config.lua` (Nix-managed symlink). Available themes:
- Gruvbox (default)
- Vague
- OneDark
- Nightfox
- Arthur
- Autumn
- Black Metal
- Catppuccin
- Tokyo Night
- VS Code
- Ayu

Statusline highlights automatically adapt to active colorscheme via `lua/statusline-highlights.lua`.

### Language Servers

LSP configurations are in `lua/plugins-config.lua`. Currently supported:
- **Bash**: bash-language-server
- **Go**: gopls, golangci-lint-langserver
- **JSON**: vscode-json-language-server
- **Lua**: lua-language-server
- **Markdown**: marksman
- **Nix**: nixd (with NixOS/Darwin/Home Manager options)
- **Python**: pyright
- **R**: R Language Server
- **Typst**: tinymist
- **YAML**: yaml-language-server (with Quarto schema validation)
- **Copilot**: copilot-language-server

Modify as needed for your development environment. LSP capabilities are defined early in the file and used by all language server configs.

### Document Settings

Quarto and R integration settings can be found in `lua/plugins-config.lua`. Obsidian workspace paths may need adjustment for your setup (currently `~/Obsidian/Notes/` and `~/Obsidian/Personal/`).

### Core Settings

- **Options**: `lua/core/options.lua` - Vim options and diagnostics
- **Keymaps**: `lua/core/keymaps.lua` - All key mappings
- **Autocommands**: `lua/core/autocommands.lua` - Autocommands and user commands
- **Helper Functions**: `lua/core/functions.lua` - Sessions, git caching, plugin management

## Troubleshooting

### Plugin Issues

- Run `:PackClean` then `:PackSync` to refresh plugins
- Check `:checkhealth` for system dependencies
- Ensure plugins are in `~/.local/share/nvim/site/pack/core/start/`
- View plugin status: `:PackStatus`
- Check for available updates: `:PackCheck`

### LSP Issues

- Ensure language servers are installed system-wide
- Check LSP configuration: `:checkhealth vim.lsp`
- Use `<leader>tr` to toggle R language server
- Verify filetype association in plugins-config.lua FileType autocmd

### Performance

- Image rendering can be toggled with `<leader>ti`
- Check startup time: `nvim --startuptime startup.log`
- All plugins are eager-loaded for immediate availability
- Disable unused plugins in `lua/plugins-pack.lua`

### Session Management

- Sessions auto-save on exit to `~/.local/state/nvim/sessions/last.vim`
- Manual save: `<leader>ps`
- Load last session: `<leader>pl`
- Select session: `<leader>pS`

### Spell Language

- Check current spell language: `:set spelllang?`
- Set project spell language: `<leader>tl` (creates `.nvim_spell_lang` file)
- Toggle spell: `<leader>ts`

## Design Philosophy

This configuration emphasizes:

1. **Native First**: Use built-in Vim/Neovim functionality when possible (`:bnext/:bprevious` instead of buffer tabs)
2. **Plugin Efficiency**: Avoid duplicate functionality (Snacks.nvim for picker, GitHub integration)
3. **Neovim 0.12+**: Leverage modern Neovim features (vim.lsp, vim.system, native package manager)
4. **Minimal UI**: Clean interface without startup screens or buffer tabs
5. **Productivity Focus**: Balance powerful features with simplicity and performance
6. **Project-Aware**: Spell language per project, auto-saved sessions, git branch caching

## License

This configuration is provided as-is.
