# Plan: Syntax-aware incremental/decremental selection

## Context

The configuration currently maps `vn` / `vs` to Neovim 0.12 LSP selection ranges in `lua/core/keymaps.lua`. This is server-dependent and therefore not a reliable all-filetype selection workflow. Tree-sitter is installed and started per filetype, but `nvim-treesitter` is pinned to its `main` rewrite, which no longer includes its former incremental-selection module.

The goal is to add dependable syntax-aware expand/shrink selection with the smallest sustainable configuration footprint, preferably reusing installed components.

## Research findings

- Neovim 0.12: `vim.lsp.buf.selection_range()` supports expand/shrink only when an attached LSP implements `textDocument/selectionRange`; this is the current `vn` / `vs` implementation.
- `nvim-treesitter` main: the former plugin incremental-selection module is gone. It is unnecessary here because Neovim 0.12 itself now supplies Tree-sitter node selection.
- Built-in Tree-sitter: Visual `an` selects a parent node and `in` selects the previous/first child; both fall back to LSP selection range when no parser exists. The underlying `vim.treesitter.select("parent" | "child")` API starts/adjusts Visual selection, including from Normal mode. This was verified locally on Neovim 0.12.3.
- `mini.ai` is installed only as `mini.surround`; adding `mini.ai` would enable richer Tree-sitter text objects and repeated Visual expansion, but cannot shrink selection. It does not meet the requested expand/shrink workflow by itself.
- `nvim-treesitter-textobjects`, `treesitter-modules.nvim`, and `incselect.nvim` add dependencies to reproduce or extend older behavior. None is needed for universal node-parent/node-child selection in this configuration.

## Approach

Use Neovim’s built-in Tree-sitter selection API; add no plugin and no parser/query configuration.

1. Replace the LSP-only `vn` / `vs` mappings in `lua/core/keymaps.lua` with a small shared callback.
2. If the current buffer has a Tree-sitter parser, call `vim.treesitter.select("parent")` for `vn` and `vim.treesitter.select("child")` for `vs`. This enters Visual mode when started from Normal mode, then traverses the syntax-node hierarchy on repeated presses.
3. If no parser can be obtained, retain the existing LSP selection-range invocation (`0` for expand, `-1` for shrink), preserving the current semantic fallback rather than doing nothing.
4. Keep built-in Visual `an` / `in` available as their native equivalents; do not add `mini.ai` or another selection plugin.

## Files to modify

- `lua/core/keymaps.lua` — replace the two LSP-only mappings with the Tree-sitter-first callback and LSP fallback.
- `README.md` — revise the key-binding description from LSP selection ranges to syntax-aware Tree-sitter selection with LSP fallback.

No plugin declaration or plugin configuration files change.

## Reuse

- `lua/plugins-pack.lua`: existing eager `nvim-treesitter` installation; no additional dependency is required.
- `lua/plugins-config.lua`: existing FileType autocmd starts Tree-sitter and already makes syntax nodes available in supported buffers.
- `lua/core/keymaps.lua`: replace the existing adjacent `vn` / `vs` mappings in place.
- Neovim 0.12 built-ins: `vim.treesitter.get_parser()`, `vim.treesitter.select()`, and `vim.lsp.buf.selection_range()`.

## Steps

- [x] Add one local selection helper near the current `vn` / `vs` mappings. It checks parser availability, selects a parent/child Tree-sitter node when available, and otherwise calls the existing LSP expand/shrink request.
- [x] Map Normal and Visual `vn` to the helper’s parent/expand action and `vs` to its child/shrink action, retaining their descriptions with syntax-aware wording.
- [x] Update the README’s Code, Diagnostics, and LSP key-binding entries to describe `vn` / `vs` accurately.

## Verification

- In a Tree-sitter-enabled Lua buffer, place the cursor in nested code. Press `vn` repeatedly: it should enter Visual mode and select progressively larger parent nodes. Press `vs` repeatedly: it should return through child nodes.
- Repeat in Markdown and Quarto, including an embedded-code area where its parser is available; verify each uses the relevant syntax tree.
- In a buffer without a Tree-sitter parser but with an LSP that supports `selectionRange`, verify `vn` / `vs` retain the existing LSP behavior.
- In a buffer with neither capability, verify the mappings fail harmlessly.
- Verify `an` / `in` remain available in Visual mode, CriticMarkup `i*` / `a*` operator-pending text objects still work in Markdown/Quarto, and `mini.surround` mappings remain unaffected.
