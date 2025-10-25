# Neovim 0.11 → 0.12 Migration Plan

**Goal:** Create a testing ground for Neovim 0.12 features while incorporating essential academic workflow tools

**Strategy:** Phased **integration leveraging** native 0.12 features (autocomplete, vim.lsp.config, vim.pack)

## Configuration Goals

- **Primary:** Testing ground for 0.12 features
- **Completion:** Native 0.12 autocomplete + completefuzzycollect
- **Essential Categories:**
  - Academic writing (Quarto, Markdown, Obsidian)
  - AI tools (Copilot, Sidekick)
  - Advanced editing (conform, mini.nvim, flash)
  - Git tools (lazygit, gitsigns)

## Comprehensive Assessment: 0.11 → 0.12

### ✅ WILL TRANSFER DIRECTLY (No Modifications Needed)

**1. Vim Options** (from `lua/core/options.lua`)

Most settings are version-agnostic and will transfer perfectly. Notable additions to 0.12 config:

- `breakindent` + `showbreak = "↪ "` for better line wrapping
- `cmdheight = 0` (cleaner UI)
- Backup/swap file management
- Better undo settings (undodir)

**2. Keymaps** (from `lua/core/keymaps.lua`)

All 100+ keymaps are version-agnostic. Your organized prefix structure (`<leader>f`, `<leader>g`, `<leader>m`, etc.) will work perfectly.

Notable ones to add:

- `<C-s>` / `<C-a>` for save/save-all
- `gh/gl` for line beginning/end
- `<Tab>/<S-Tab>` for buffer cycling
- Centered scrolling with `<C-u>/<C-d>`

**3. Autocmds** (from `lua/core/autocommands.lua`)

All autocmds are compatible:

- Session management functions
- Markdown heading navigation (`]]`, `[[`)
- Spell language auto-detection

**4. Snippets** (entire `snippets/` directory)

Your VSCode-style JSON snippets will work with LuaSnip unchanged. All 6 files (markdown, quarto, r, nix, all, package) can be copied.

**5. Filetype Configs** (`ftplugins/`)

Both markdown.lua and quarto.lua are version-agnostic and can be copied directly.

### 🔧 NEEDS MODIFICATION FOR 0.12

**1. LSP Configuration**

- ✅ ALREADY DONE: Your 0.12 config uses `vim.lsp.config()` API
- Just need to add pyright and yamlls
- Consider: Keep R LSP always enabled (your 0.11 has toggle, but for testing simplify it)

**2. Completion System**

- ✅ ALREADY CONFIGURED: Native 0.12 `autocomplete` + `completefuzzycollect`
- ❌ DON'T PORT: blink.cmp from 0.11 (not needed with native completion)
- ✅ KEEP: LuaSnip for custom snippets (loaded, but native completion handles keywords)
- Need to configure: LuaSnip to load from `snippets/` directory

**3. Plugin Management**

- ✅ ALREADY USING: Native `vim.pack` instead of paq-nvim
- Need to add: Optional plugin loading support (for lazy-loading on commands/filetypes)
- Strategy: Use `pack/plugins/opt/` directory and `vim.cmd.packadd()` for lazy loading

### ✅ PLUGINS TO ADD (0.12 Compatible)

**Academic Writing (8 plugins):**

1. `quarto-nvim` - Quarto document support [LAZY: ft=quarto]
2. `obsidian.nvim` - Note management [LAZY: ft=markdown]
3. `render-markdown.nvim` - Live markdown rendering [LAZY: ft=markdown,quarto]
4. `otter.nvim` - Embedded code LSP [LAZY: ft=quarto]
5. `vim-markdown` - Markdown navigation [LAZY: ft=markdown]
6. `cmp-pandoc-references` - Citation completion [LAZY: ft=markdown,quarto]
7. `image.nvim` - Image rendering [LAZY: ft=markdown,quarto]
8. `img-clip.nvim` - Image pasting [LAZY: ft=markdown,quarto]

**AI Tools (2 plugins):**

1. `copilot.vim` - GitHub Copilot [EAGER]
2. `sidekick.nvim` - Claude AI assistant [EAGER]

**Advanced Editing (5 plugins):**

1. `conform.nvim` - Code formatting [EAGER]
2. `mini.nvim` (icons, pairs, surround, indentscope) [EAGER]
3. `flash.nvim` - Enhanced jump motions [EAGER]
4. `nvim-colorizer.lua` - Color code visualization [LAZY: cmd]
5. `which-key.nvim` - Keymap help [EAGER]

**Git Tools (2 plugins):**

1. `lazygit.nvim` - Git UI [LAZY: cmd=LazyGit]
2. ✅ Already have: gitsigns.nvim [EAGER]

**Supporting Libraries:**

1. `vim-tmux-navigator` - Seamless vim/tmux navigation [EAGER]
2. `friendly-snippets` - VSCode snippet library [EAGER]
3. ✅ Already have: plenary.nvim, nvim-web-devicons

### ❌ WON'T PORT (Redundant or Not Needed)

1. **paq-nvim** - Replaced by native `vim.pack`
2. **lz.n** - Use simpler native lazy loading with `packadd`
3. **blink.cmp** - Using native 0.12 completion
4. **nvim-lspconfig** - Replaced by native `vim.lsp.config()`
5. **bufferline.nvim** - Keep it minimal (use FzfLua for buffer switching)
6. **alpha-nvim** - Keep startup fast for testing
7. **fidget.nvim / nvim-notify** - Use native notifications for now
8. **toggleterm.nvim** - Already have Yazi, keep it simple
9. **aerial.nvim** - Can use FzfLua symbols instead
10. **todo-comments.nvim** - Can add later if needed
11. **csvview.nvim** - Specialized, add if needed
12. **snacks.nvim** - Not essential for testing

### 🟡 QUESTIONABLE (Need Compatibility Check)

These plugins might have 0.12 compatibility issues:

1. **image.nvim** - Uses ImageMagick, might need testing
2. **render-markdown.nvim** - Heavy UI manipulation, test carefully
3. **obsidian.nvim** - Complex plugin, verify 0.12 compatibility

**Strategy:** Add these last, one at a time, and test thoroughly

## Summary Statistics

**Current 0.12 Config:**

- Plugins: 8 (all eager-loaded)
- Keymaps: ~30
- Lines: 505

**Proposed Enhanced 0.12 Config:**

- Plugins: ~25 (12 eager, 13 lazy)
- Keymaps: ~100+ (organized by prefix)
- Additional: snippets/, ftplugins/, custom functions
- Estimated lines: ~900-1000

## Phased Integration Plan

### Phase 1: Foundation (Core Enhancements)

1. **Add improved vim options** from 0.11 (breakindent, cmdheight, undodir, etc.)
2. **Port all keymaps** organized by prefix (`<leader>f`, `<leader>g`, etc.)
3. **Add custom functions** (toggle functions, session management)
4. **Enhanced autocmds** (spell language detection, markdown navigation)
5. **Add Python LSP** (pyright) and **YAML LSP** (yamlls) to existing LSP configs

### Phase 2: Snippet System

1. **Create `snippets/` directory structure** in nvim-dev
2. **Copy all 6 snippet files** from 0.11 config
3. **Configure LuaSnip** to load VSCode-style snippets from directory
4. **Add friendly-snippets** plugin for additional snippet library
5. **Keep native completion** for keyword/fuzzy matching

### Phase 3: Essential Plugins (Eager-Loaded)

Add core plugins that should always be available:

1. `conform.nvim` - Formatting with shfmt, stylua, mdformat, alejandra, ruff
2. `mini.nvim` (4 modules) - Icons, pairs, surround, indentscope
3. `flash.nvim` - Jump motions
4. `copilot.vim` - AI assistance
5. `sidekick.nvim` - Claude AI
6. `which-key.nvim` - Keymap help
7. `vim-tmux-navigator` - Tmux integration
8. `nvim-web-devicons` - File icons

### Phase 4: Lazy-Loaded Plugins

Implement opt plugin loading system:

1. **Create helper function** for lazy loading with `packadd`
2. **Add lazy plugins:**
   - `lazygit.nvim` (cmd: LazyGit)
   - `quarto-nvim` (ft: quarto)
   - `otter.nvim` (ft: quarto)
   - `obsidian.nvim` (ft: markdown)
   - `render-markdown.nvim` (ft: markdown, quarto)
   - `vim-markdown` (ft: markdown, quarto)
   - `cmp-pandoc-references` (ft: markdown, quarto)
   - `nvim-colorizer.lua` (cmd: ColorizerToggle)

### Phase 5: Advanced Features (Test Carefully)

Add potentially problematic plugins one at a time:

1. `image.nvim` - Test image rendering
2. `img-clip.nvim` - Test image pasting

### Phase 6: Filetype Configurations

1. **Create `ftplugins/` directory**
2. **Copy markdown.lua** and **quarto.lua** from 0.11
3. **Verify behavior** with Quarto documents

### Phase 7: Theme Integration

1. **Add gruvbox.nvim** (your preferred theme from 0.11)
2. **Configure hard contrast + inverted selection**
3. **Set up theme-specific highlights** for Copilot/Sidekick
4. **Keep tokyonight** as fallback option

## Key Implementation Details

### Lazy Loading Pattern (Native vim.pack)

Instead of lz.n, we'll use a simpler pattern:

```lua
-- Install to opt directory
local function install_opt_plugin(url, name)
  local install_path = vim.fn.stdpath("data") .. "/site/pack/plugins/opt/" .. name
  -- ... same git clone logic
end

-- Load on filetype
vim.api.nvim_create_autocmd("FileType", {
  pattern = "quarto",
  callback = function()
    vim.cmd.packadd("quarto-nvim")
    require("quarto").setup({...})
  end,
  once = true,
})

-- Load on command
vim.api.nvim_create_user_command("LazyGit", function()
  vim.cmd.packadd("lazygit.nvim")
  require("lazygit").lazygit()
end, {})
```

### Native Completion + LuaSnip Integration

```lua
-- LuaSnip setup with snippet loading
require("luasnip.loaders.from_vscode").lazy_load({
  paths = { vim.fn.stdpath("config") .. "/snippets" }
})

-- Native completion uses keyword matching
-- LuaSnip provides snippet expansion with <Tab>
vim.keymap.set({"i", "s"}, "<Tab>", function()
  if require("luasnip").expand_or_jumpable() then
    require("luasnip").expand_or_jump()
  else
    return "<Tab>"
  end
end, { expr = true })
```

### LSP Configuration Updates

Just add to existing vim.lsp.config calls:

```lua
-- Python
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
  on_attach = on_attach,
})

-- YAML with Quarto schema support
vim.lsp.config("yamlls", {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yml" },
  root_markers = { ".git" },
  on_attach = on_attach,
  settings = {
    yaml = {
      schemas = {
        -- Auto-detect Quarto schema if available
        ["https://raw.githubusercontent.com/quarto-dev/quarto-cli/main/src/resources/yaml-intelligence-resources/quarto-editor-schema.json"] = "*.qmd",
      },
    },
  },
})
```

## Compatibility Concerns

### High Risk (Test Last)

- `image.nvim` - ImageMagick dependencies, complex rendering
- `render-markdown.nvim` - Extensive UI modifications
- `obsidian.nvim` - Large plugin, might have API assumptions

### Medium Risk (Test Early)

- `quarto-nvim` - Core workflow plugin, needs verification
- `sidekick.nvim` - Newer plugin, might need updates
- `otter.nvim` - Depends on LSP APIs

### Low Risk (Should Work)

- All mini.nvim modules (well-maintained)
- conform.nvim (stable, popular)
- copilot.vim (Vimscript, stable)
- flash.nvim (well-maintained)
- lazygit.nvim (simple wrapper)

## Structure Recommendations

Keep it as a single `init.lua` file for now (testing phase), but organize with clear sections:

```
nvim-dev/
├── init.lua (900-1000 lines)
│   ├── 1. Core Settings (vim options)
│   ├── 2. New 0.12 Features
│   ├── 3. Plugin Management (start + opt)
│   ├── 4. Plugin Configurations
│   ├── 5. LSP Configuration
│   ├── 6. Completion + Snippets
│   ├── 7. Treesitter
│   ├── 8. Keymaps (organized by prefix)
│   ├── 9. Custom Functions
│   ├── 10. Autocommands
│   └── 11. UI/Highlights
├── snippets/
│   ├── all.json
│   ├── markdown.json
│   ├── quarto.json
│   ├── r.json
│   ├── nix.json
│   └── package.json
└── ftplugins/
    ├── markdown.lua
    └── quarto.lua
```

Once stable, you can modularize later if desired.

## Status

- [x] Plan created
- [ ] Phase 1: Foundation
- [ ] Phase 2: Snippet System
- [x] Phase 3: Essential Plugins
- [ ] Phase 4: Lazy-Loaded Plugins
- [ ] Phase 5: Advanced Features
- [ ] Phase 6: Filetype Configurations
- [ ] Phase 7: Theme Integration
