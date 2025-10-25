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

### Phase 1: Foundation (Core Enhancements) ✅ COMPLETE

1. **Add improved vim options** from 0.11 (breakindent, cmdheight, undodir, etc.) ✅
2. **Port all keymaps** organized by prefix (`<leader>f`, `<leader>g`, etc.) ✅
3. **Add custom functions** (toggle functions, session management) ✅
4. **Enhanced autocmds** (spell language detection, markdown navigation) ✅
5. **Add Python LSP** (pyright) and **YAML LSP** (yamlls) to existing LSP configs ✅

All foundation elements are in place with 100+ keymaps, comprehensive autocmds, and full LSP coverage.

### Phase 2: Snippet System ✅ COMPLETE

1. **Create `snippets/` directory structure** in nvim-dev ✅
2. **Copy all 6 snippet files** from 0.11 config ✅
3. **Configure LuaSnip** to load VSCode-style snippets from directory ✅
4. **Add friendly-snippets** plugin for additional snippet library ✅
5. **Keep native completion** for keyword/fuzzy matching ✅

All snippets are loaded and working with native 0.12 completion. Custom snippets in snippets/ directory, friendly-snippets provides additional library.

### Phase 3: Essential Plugins (Eager-Loaded) 7/8 COMPLETE

Add core plugins that should always be available:

1. `conform.nvim` - Formatting with shfmt, stylua, mdformat, alejandra, ruff ✅
2. `mini.nvim` (4 modules) - Icons, pairs, surround, indentscope ✅
3. `flash.nvim` - Jump motions ✅
4. `copilot.vim` - AI assistance ✅
5. `sidekick.nvim` - Claude AI ❌ NOT INSTALLED
6. `which-key.nvim` - Keymap help ✅
7. `vim-tmux-navigator` - Tmux integration ✅
8. `nvim-web-devicons` - File icons ✅

Note: sidekick.nvim is optional. All other essential plugins are installed and configured.

### Phase 4: Lazy-Loaded Plugins ✅ COMPLETE

Implement opt plugin loading system:

1. **Create helper function** for lazy loading with `packadd` ✅
2. **Add lazy plugins:**
   - `lazygit.nvim` (cmd: LazyGit) ✅
   - `quarto-nvim` (ft: quarto) ✅
   - `otter.nvim` (ft: quarto) ✅
   - `obsidian.nvim` (ft: markdown) ✅
   - `render-markdown.nvim` (ft: markdown, quarto) ✅
   - `vim-markdown` (ft: markdown, quarto) ✅
   - `cmp-pandoc-references` (ft: markdown, quarto) ✅
   - `nvim-colorizer.lua` (cmd: ColorizerToggle) ✅

All lazy-loaded plugins are configured with proper FileType and Command triggers using native vim.pack.

### Phase 5: Advanced Features (Test Carefully) ✅ COMPLETE

Both image plugins installed and configured:

1. `image.nvim` - Image rendering in terminal ✅ INSTALLED (init.lua:712-748)
2. `img-clip.nvim` - Image pasting from clipboard ✅ INSTALLED (init.lua:750-785)

**Important Notes:**

- **Terminal Requirements:** Image rendering requires a terminal with image protocol support:
  - Kitty (recommended, uses Kitty graphics protocol)
  - iTerm2 (on macOS)
  - WezTerm
  - Or ueberzug for X11 systems
- **Tmux Users:** Add to `~/.tmux.conf`: `set -gq allow-passthrough on`
- **Backend:** Config auto-detects best backend (Kitty protocol by default, ueberzug if available)
- **Keybindings:** `<leader>mp` in markdown/quarto files to paste images from clipboard
- **Dependencies:** Requires ImageMagick (magick command) - ✅ verified installed at `/etc/profiles/per-user/francojc/bin/magick`
- **Lazy Loading:** Both plugins load only when opening markdown or quarto files
- **Version Compatibility:** Config includes 0.11 backward compatibility checks

### Phase 6: Filetype Configurations ⏸️ OPTIONAL

1. **Create `ftplugin/` directory** ❌ NOT CREATED
2. **Copy markdown.lua** and **quarto.lua** from 0.11 ❌ NOT CREATED
3. **Verify behavior** with Quarto documents

Note: Currently all markdown/quarto functionality is handled via autocmds (init.lua:1318-1345). Filetype plugins are optional organizational preference. The ftplugin approach would be cleaner but functionally equivalent to current autocmd approach.

### Phase 7: Theme Integration 3/4 COMPLETE

1. **Add gruvbox.nvim** (your preferred theme from 0.11) ✅
2. **Configure hard contrast + inverted selection** ✅
3. **Set up theme-specific highlights** for Copilot/Sidekick ❌ NOT CONFIGURED
4. **Keep tokyonight** as fallback option ✅

Multiple themes are installed and configured (tokyonight, gruvbox, nightfox, onedark, vague, arthur, autumn, black-metal). Gruvbox has hard contrast and invert_selection configured. Theme-specific AI assistant highlights are optional polish items.

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

## Current Status Assessment

### Completed Phases

**Phase 1: Foundation** ✅ COMPLETE

- All vim options configured (init.lua:19-96)
- All keymaps ported and organized by prefix (init.lua:999-1145)
- Custom functions added (init.lua:1160-1267)
- Enhanced autocmds implemented (init.lua:1273-1405)
- Python LSP (pyright) configured (init.lua:876-891)
- YAML LSP (yamlls) configured with Quarto schema (init.lua:893-910)

**Phase 2: Snippet System** ✅ COMPLETE

- snippets/ directory created with all 6 files present
- LuaSnip configured to load from snippets directory (init.lua:366-413)
- friendly-snippets plugin installed (init.lua:172-173)
- Native 0.12 completion active (init.lua:103-116)
- Keymaps for snippet navigation configured (Ctrl+j/k for jump, Ctrl+Space for expand)

**Phase 4: Lazy-Loaded Plugins** ✅ COMPLETE

All academic and utility plugins configured with proper lazy loading:

- quarto-nvim (init.lua:200, 572-599) - FileType trigger
- otter.nvim (init.lua:201, 602-622) - FileType trigger
- obsidian.nvim (init.lua:202, 625-647) - FileType trigger
- render-markdown.nvim (init.lua:203-206, 650-677) - FileType trigger
- vim-markdown (init.lua:207, 680-693) - FileType trigger
- cmp-pandoc-references (init.lua:208-209, 696-703) - FileType trigger
- lazygit.nvim (init.lua:212, 706-735) - Command trigger
- nvim-colorizer.lua (init.lua:213-214, 738-744) - Command trigger

### Partially Complete Phases

**Phase 3: Essential Plugins** 7/8 COMPLETE

- ✅ conform.nvim (init.lua:187) - Formatting with stylua, ruff, shfmt, mdformat, alejandra, prettier
- ✅ mini.nvim (init.lua:188) - 4 modules: icons, pairs, surround, indentscope
- ✅ flash.nvim (init.lua:189) - Enhanced jump motions
- ✅ copilot.vim (init.lua:190) - GitHub Copilot AI assistance
- ❌ **sidekick.nvim** - NOT INSTALLED (Claude AI assistant)
- ✅ which-key.nvim (init.lua:191) - Keymap help
- ✅ vim-tmux-navigator (init.lua:192) - Seamless vim/tmux navigation
- ✅ nvim-web-devicons (init.lua:194) - File icons

**Phase 7: Theme Integration** 3/4 COMPLETE

- ✅ Multiple themes installed and configured:
  - tokyonight (default, init.lua:230, 279-289)
  - gruvbox with hard contrast + invert_selection (init.lua:252-258)
  - nightfox, onedark, vague, arthur, autumn, black-metal (init.lua:260-294)
- ✅ Gruvbox configured with hard contrast setting
- ✅ Theme selection system in place (init.lua:229-236)
- ❌ **Theme-specific highlights for Copilot/Sidekick** - NOT CONFIGURED

### Completed Optional Phases

**Phase 5: Advanced Features** ✅ COMPLETE

Both high-risk image plugins have been successfully installed and configured:

- ✅ image.nvim - INSTALLED (init.lua:712-748, requires terminal with image protocol support)
- ✅ img-clip.nvim - INSTALLED (init.lua:750-785, provides clipboard image pasting)

**Phase 6: Filetype Configurations**

- ❌ ftplugin/ directory - DOES NOT EXIST
- ❌ markdown.lua - NOT CREATED
- ❌ quarto.lua - NOT CREATED

Note: Markdown/Quarto functionality is currently handled via autocmds (init.lua:1318-1345) rather than ftplugin files.

### Optional Components Not Added

1. **sidekick.nvim** - Claude AI assistant plugin (optional)
2. **ftplugin/markdown.lua** - Markdown-specific settings (optional - functionality in autocmds)
3. **ftplugin/quarto.lua** - Quarto-specific settings (optional - functionality in autocmds)
4. **Theme-specific highlights** - Custom highlights for AI assistant suggestions (polish item)

## 0.12+ Specific Enhancements

These are additional Neovim 0.12+ features that could enhance the config beyond the original plan:

### 1. Native Snippet API Integration

Neovim 0.12 introduces `vim.snippet` API that can work alongside LuaSnip:

```lua
-- Integration with native snippet API
if vim.snippet then
  vim.keymap.set({"i", "s"}, "<C-Space>", function()
    if vim.snippet.active() then
      return vim.snippet.expand()
    elseif require("luasnip").expandable() then
      return require("luasnip").expand()
    end
  end, { silent = true, desc = "Expand snippet (native or LuaSnip)" })
end
```

### 2. Enhanced LSP Completion Configuration

0.12 adds `vim.lsp.completion` module for better control:

```lua
-- In on_attach function
vim.lsp.completion.enable(true, nil, bufnr, {
  autotrigger = true,
  convert = function(item)
    -- Customize completion item appearance
    return item
  end
})
```

### 3. Improved Diagnostic Virtual Text

Enhanced virtual_text options with source display and custom formatting:

```lua
-- Update diagnostic config
vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = {
    prefix = "●",
    severity = { min = vim.diagnostic.severity.INFO },
    source = "if_many",  -- Show source when multiple servers provide diagnostics
    format = function(diagnostic)
      return string.format("%s [%s]", diagnostic.message, diagnostic.source or "")
    end,
  },
  -- ... rest of config
})
```

### 4. Popup Menu Visual Enhancements

```lua
vim.opt.pumblend = 10      -- Slight transparency for popup menu
vim.opt.pumheight = 15     -- Limit popup menu height
vim.opt.pummaxwidth = 60   -- Already configured

-- Custom completion menu highlights
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#7aa2f7", fg = "#1a1b26", bold = true })
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#7aa2f7" })
vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#16161e" })
```

### 5. Treesitter Textobjects for Academic Writing

```lua
-- Add to treesitter configuration
require("nvim-treesitter.configs").setup({
  -- ... existing config
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ap"] = "@parameter.outer",
        ["ip"] = "@parameter.inner",
      },
    },
  },
})
```

### 6. LSP Codelens Support

For R and Python language servers that support codelens:

```lua
-- In on_attach function
if client.server_capabilities.codeLensProvider then
  vim.lsp.codelens.refresh()
  vim.api.nvim_create_autocmd({"BufEnter", "CursorHold", "InsertLeave"}, {
    buffer = bufnr,
    callback = vim.lsp.codelens.refresh,
  })

  vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run,
    { buffer = bufnr, desc = "Run codelens" })
end
```

### 7. Additional Diff Highlight Groups

Expand beyond DiffTextAdd to full diff highlighting:

```lua
-- Add to UI section
vim.api.nvim_set_hl(0, "DiffTextAdd", { bg = "#3d5213", fg = "#b4fa72" })
vim.api.nvim_set_hl(0, "DiffTextDelete", { bg = "#5a1a1a", fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "DiffTextChange", { bg = "#3a3a1a", fg = "#dbc074" })
vim.api.nvim_set_hl(0, "Added", { fg = "#b4fa72" })
vim.api.nvim_set_hl(0, "Removed", { fg = "#ff6b6b" })
vim.api.nvim_set_hl(0, "Changed", { fg = "#dbc074" })
```

### 8. Native File Browser Enhancement

0.12 has improved `vim.ui.open()` for system integration:

```lua
-- Open current file with system default application
vim.keymap.set("n", "<leader>fo", function()
  vim.ui.open(vim.fn.expand("%:p"))
end, { desc = "Open file with system default" })
```

### 9. Academic Workflow: Citation Preview

For Quarto/Markdown with pandoc citations:

```lua
-- Add to markdown/quarto autocmd or ftplugin
vim.keymap.set("n", "<leader>mc", function()
  local word = vim.fn.expand("<cWORD>")
  if word:match("@%w+") then
    -- Show citation details in floating window
    vim.lsp.buf.hover()
  end
end, { buffer = true, desc = "Preview citation" })
```

### 10. Enhanced Session Management with 0.12 APIs

Leverage improved session APIs:

```lua
-- Add to session management functions
local function session_save_enhanced(name, opts)
  opts = opts or {}
  vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
  -- Use new vim.fn.system with table arguments for better error handling
  local target = session_path(name)
  local ok = pcall(vim.cmd.mksession, { args = { target }, bang = true })
  return ok and target or nil
end
```

### Implementation Priority

**High Priority** (Immediate value):

- #3: Enhanced diagnostic virtual text formatting
- #4: Popup menu visual enhancements
- #7: Additional diff highlight groups
- #8: Native file browser integration

**Medium Priority** (Nice to have):

- #2: LSP completion configuration
- #5: Treesitter textobjects
- #9: Citation preview for academic workflow

**Low Priority** (Experimental):

- #1: Native snippet API (LuaSnip already working well)
- #6: Codelens support (depends on server capabilities)
- #10: Enhanced session management (current system works)

## Status

- [x] Plan created
- [x] Phase 1: Foundation
- [x] Phase 2: Snippet System
- [x] Phase 3: Essential Plugins (7/8 - missing sidekick.nvim)
- [x] Phase 4: Lazy-Loaded Plugins
- [x] Phase 5: Advanced Features (image.nvim + img-clip.nvim installed)
- [ ] Phase 6: Filetype Configurations (optional - functionality handled via autocmds)
- [x] Phase 7: Theme Integration (3/4 - themes configured, missing AI highlights)
