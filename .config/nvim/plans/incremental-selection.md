# Plan: Syntax-aware incremental/decremental selection

## Context

The configuration currently maps `vn` / `vs` to Neovim 0.12 LSP selection ranges in `lua/core/keymaps.lua`. This is server-dependent and therefore not a reliable all-filetype selection workflow. Tree-sitter is installed and started per filetype, but `nvim-treesitter` is pinned to its `main` rewrite, which no longer includes its former incremental-selection module.

The goal is to add dependable syntax-aware expand/shrink selection with the smallest sustainable configuration footprint, preferably reusing installed components.

## Initial research

- Neovim 0.12: `vim.lsp.buf.selection_range()` supports expand/shrink only when an attached LSP implements `textDocument/selectionRange`.
- `nvim-treesitter` main: parser/query infrastructure is present, but the former integrated incremental-selection module is absent.
- `mini.ai`: can provide Tree-sitter-backed text objects and repeated Visual expansion, but it explicitly has no decrement/shrink selection feature.
- Candidate external solution: `nvim-treesitter/nvim-treesitter-textobjects` provides syntax-aware selection primitives, but selection expansion/decrement behavior and compatibility with the current Tree-sitter main branch need confirmation before recommendation.

## Approach

Pending desired interaction model: choose the smallest solution that supplies both syntax-aware expansion and shrink, retain LSP selection as an optional semantic supplement, and avoid overlapping/conflicting mappings.

## Files to modify

Likely:

- `lua/plugins-pack.lua` — only if the selected solution needs a plugin.
- `lua/plugins-config.lua` — configure the selected Tree-sitter/text-object capability.
- `lua/core/keymaps.lua` — replace or supplement `vn` / `vs` mappings.
- `README.md` — document the final mappings.

## Reuse

- `lua/plugins-pack.lua`: existing eager `nvim-treesitter` and `mini.surround` declarations.
- `lua/plugins-config.lua`: existing `vim.treesitter.start` FileType autocmd.
- `lua/core/keymaps.lua`: existing LSP selection mappings.

## Steps

- [ ] Confirm intended selection behavior, scope, and keybinding preference.
- [ ] Verify viable Tree-sitter selection implementations against Neovim 0.12 and `nvim-treesitter` main.
- [ ] Select and configure the minimal compatible implementation.
- [ ] Define non-conflicting expand/shrink mappings and decide the fate of `vn` / `vs`.
- [ ] Document and test the selection ladder across representative filetypes.

## Verification

- In Lua, Markdown, and Quarto buffers, place the cursor in a nested expression/construct and repeatedly expand then shrink selection.
- Verify a selection can be used directly with operators (for example `d`, `c`, `y`) where applicable.
- Confirm mappings work without an attached LSP and do not disrupt existing CriticMarkup text objects or `mini.surround`.
- Verify existing `vn` / `vs` behavior is retained, moved, or removed as chosen.
