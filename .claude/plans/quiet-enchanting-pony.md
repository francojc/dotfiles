# Fix: Tinymist LSP Not Attaching to Typst Files

## Root Cause Identified

The tinymist LSP is correctly installed via Nix and properly configured in `lua/plugins-config.lua`, but it's not auto-enabling when you open `.typ` files.

**The Problem:** In `lua/plugins-config.lua` (lines 512-546), the FileType autocommand includes `"typst"` in its pattern list, but the `server_map` dictionary is missing the mapping for typst files.

Current server_map (line 519-533):
```lua
local server_map = {
  sh = "bashls",
  bash = "bashls",
  lua = "lua_ls",
  markdown = "marksman",
  nix = "nixd",
  python = "pyright",
  r = "r_language_server",
  rmd = "r_language_server",
  quarto = "r_language_server",
  yaml = "yamlls",
  yml = "yamlls",
  -- typst is MISSING here!
}
```

When a `.typ` file opens:
1. Neovim detects filetype as "typst" ✓
2. FileType autocommand triggers (pattern matches) ✓
3. Callback looks up "typst" in server_map ✗
4. No mapping found, so `vim.lsp.enable()` never called ✗

## Recommended Fix

Add the missing mapping to `server_map` in `lua/plugins-config.lua`:

**File:** `lua/plugins-config.lua`
**Location:** Line ~533 (inside the server_map table)
**Change:** Add `typst = "tinymist",` to the server_map

```lua
local server_map = {
  sh = "bashls",
  bash = "bashls",
  lua = "lua_ls",
  markdown = "marksman",
  nix = "nixd",
  python = "pyright",
  r = "r_language_server",
  rmd = "r_language_server",
  quarto = "r_language_server",
  typst = "tinymist",  -- ADD THIS LINE
  yaml = "yamlls",
  yml = "yamlls",
}
```

## Verification

After making this change, tinymist should automatically attach when you:
1. Open any `.typ` file in Neovim
2. Check LSP status with `:LspInfo` - should show tinymist attached
3. Use LSP features like hover (`K`), go to definition (`gD`), etc.

## Additional Context

Your setup is otherwise complete:
- tinymist installed: `/etc/profiles/per-user/francojc/bin/tinymist` (via Nix)
- LSP config defined: `lua/plugins-config.lua:503-508`
- Preview plugin configured: `typst-preview.nvim`
- LSP keymaps ready: defined in `lua/core/keymaps.lua:223-241`
