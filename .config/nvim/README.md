# Neovim Configuration

Modular Neovim 0.12+ config using native `vim.pack`, native LSP, and small focused plugins. Core bias: built-ins first, plugins when they earn rent.

## Current Feature Set

### Editing Core

- Space is leader and localleader.
- Native buffer navigation with `<Tab>` / `<S-Tab>`.
- `jj` exits insert mode, `<Esc><Esc>` exits terminal mode.
- Relative numbers, rounded borders, smartcase search, persistent undo, system clipboard, wrapped prose by default.
- Auto-trim trailing whitespace on save and highlight yanks.
- Lualine statusline with branch, diff, diagnostics, search count, progress, location, filetype, and llama.vim status.
- Treesitter starts automatically per filetype, with regex syntax fallback.
- Which-key uses Helix preset with leader-group labels.

### Completion, Snippets, and AI

- `blink.cmp` provides LSP, path, buffer, and snippet completion.
- Friendly snippets plus local snippets from `snippets/`.
- Emoji completion for Markdown and Quarto.
- Command-line completion for `:` commands.
- `llama.vim` provides local FIM/code completion through configured llama.cpp endpoint.
  - Trigger: `<M-l>`
  - Accept full: `<Tab>`
  - Accept line: `<C-F>`
  - Accept word: `<C-D>`

### Documents and Prose

- Quarto files (`*.qmd`) use `filetype=quarto`.
- Markdown and Quarto support heading navigation with `]]` and `[[`.
- Quarto code execution uses `quarto-nvim` + `vim-slime` with tmux target.
- Otter provides embedded-code LSP support for Quarto chunks.
- Markdown and Quarto lazy-load:
  - `render-markdown.nvim`
  - `image.nvim`
  - `img-clip.nvim`
  - `snacks-bibtex.nvim`
- Markdown lazy-loads `obsidian.nvim`.
- Neovim started inside an Obsidian vault also lazy-loads Obsidian support.
- CriticMarkup support in Markdown/Quarto:
  - Visual wrappers for insert/delete/highlight/comment/substitution.
  - Text objects for CriticMarkup spans.
  - `:CriticConvert [format]` converts current file through Pandoc using `lua/core/critic.lua`.
  - `:CriticOpen` opens last converted DOCX.

### Development Tools

- Native `vim.lsp` configs with `blink.cmp` capabilities.
- Conform formatting, with format-on-save enabled except Markdown and Quarto.
- Gitsigns for hunks, blame, and word diff.
- Diffview lazy-loads on command.
- Snacks picker powers file, grep, LSP, help, search, GitHub, and UI-select workflows.
- Yazi handles directory/file exploration. Netrw plugin disabled.
- CSV/TSV viewing lazy-loads `csvview.nvim`.
- Aerial outline lazy-loads on `:AerialToggle`.
- Todo comments plugin declared and lazy command configured, with Snacks todo picker keymap.

### Language Support

| Language/type | LSP | Formatting |
| --- | --- | --- |
| Bash/sh | `bashls` | `shfmt` |
| Go | `gopls`, `golangci_lint_ls` | trim whitespace only |
| JSON | `jsonls` | `jq` |
| JSONC | `jsonls` | trim whitespace only |
| Lua | `lua_ls` | `stylua` |
| Markdown | `marksman` | `mdformat` manually, no format-on-save |
| Nix | `nixd` | `alejandra` |
| Python | `pyright` | `ruff`, with LSP fallback |
| R/Rmd | `r_language_server` | `air` for R |
| Quarto | `r_language_server`, Otter for chunks | injected formatter manually, no format-on-save |
| Typst | `tinymist` | trim whitespace only |
| YAML/YML | `yamlls` | trim whitespace only |

Notes:

- Quarto YAML schema is detected from `quarto --paths` when available.
- Nix LSP points at local dotfiles flake for NixOS, nix-darwin, and Home Manager options.
- Language servers and external formatters are expected to be installed outside this config, likely through Nix.

### Themes

Themes are declared in `lua/plugins-pack.lua`. `lua/theme-config.lua` selects active theme. Only active theme loads eagerly; other theme plugins are installed as opt packages.

Available colorscheme names:

- `arthur`
- `autumn`
- `black-metal`
- `catppuccin`
- `gruvbox`
- `kanso`
- `nightfox`
- `onedark`
- `tokyonight`
- `tokyonight-night`
- `tokyonight-storm`
- `tokyonight-moon`
- `tokyonight-day`
- `vague`
- `vscode`
- `ayu`

Current default in this directory: `gruvbox`.

## Installation

### Prerequisites

- Neovim >= 0.12
- Git
- External tools as needed:
  - LSPs: `bash-language-server`, `gopls`, `golangci-lint-langserver`, `lua-language-server`, `nixd`, `pyright`, `R` + `languageserver`, `tinymist`, `vscode-json-language-server`, `yaml-language-server`, `marksman`
  - Formatters: `shfmt`, `jq`, `stylua`, `mdformat`, `alejandra`, `ruff`, `air`
  - Document tools: `quarto`, `pandoc`, ImageMagick CLI, `yazi`, `gh`

### Setup

1. Clone, symlink, or `stow` this directory to your Neovim config directory.
2. Start Neovim.
3. `vim.pack` installs declared plugins automatically.

First launch may take a bit while plugin repos download. Tiny yak herd, normal.

## Plugin Management

This config uses native `vim.pack` plus custom helpers in `lua/core/pack-mgmt.lua`.

Commands:

```vim
:PackUpdate         " Update all plugins
:PackUpdate!        " Force update all plugins
:PackUpdatePlugin   " Update one plugin, picker when no name given
:PackCheck          " Check available updates
:PackDiagnose       " Diagnose plugin remote fetch failures
:PackStatus         " Show plugin status
:PackClean          " Remove undeclared plugins and lockfile entries
:PackSync           " Update then clean
```

Leader shortcuts:

- `<leader>uc` - Check updates
- `<leader>uu` - Update all plugins
- `<leader>uU` - Force update all plugins
- `<leader>up` - Update one plugin
- `<leader>us` - Plugin status
- `<leader>uC` - Clean unused plugins
- `<leader>uS` - Sync plugins

Startup checks for plugin updates weekly.

Current plugin shape:

- 43 unique plugin directories declared.
- Active colorscheme, completion, core UI, LSP helpers, treesitter, git signs, conform, yazi, and llama load eagerly.
- Document/data/UI extras lazy-load by filetype or command.

## Key Bindings

### Core

- `<C-s>` - Save file
- `<C-a>` - Save all files
- `<C-x>` - Quit all without saving
- `<leader>x` - Save all and quit
- `gh` / `gl` - First/last non-blank character on line
- `go` / `gO` - Add line below/above
- `j` / `k` - Move by visual line
- `<C-u>` / `<C-d>` - Half-page scroll and center
- `n` / `N` - Next/previous search result and center
- Visual `p` - Paste without overwriting register
- Visual `J` / `K` - Move selected lines down/up

### Windows and Buffers

- `<Tab>` / `<S-Tab>` - Next/previous buffer
- `<leader>bd` - Delete buffer
- `<leader>bo` - Close other buffers
- `<leader>bf` - Find buffer
- `<leader>wk` / `<leader>wj` - Resize up/down
- `<leader>wh` / `<leader>wl` - Resize left/right

### Files and Search

- `<leader><leader>` - Smart picker
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fr` - Recent files
- `<leader>fc` - Resume picker
- `<leader>fn` - New file
- `<leader>sh` - Help tags
- `<leader>sj` - Jumps
- `<leader>sk` - Keymaps
- `<leader>sm` - Marks
- `<leader>sn` - Notifications
- `<leader>sq` - Quickfix list
- `<leader>sr` - Registers
- `<leader>ss` - Spelling suggestions
- `<leader>st` - Todo comments

### Explorer

- `<leader>ey` - Open Yazi
- `<leader>ec` - Open Yazi in current working directory

### Code, Diagnostics, and LSP

- `<leader>ca` - Code actions
- `<leader>cf` - Format buffer/range through Conform
- `<leader>cn` - Collapse repeated spaces
- `<leader>dd` - Diagnostic float
- `gf` - Go to related diagnostic location
- `K` - Hover
- `gD` - Declaration
- `grt` - Type definition
- `vn` / `vs` - Expand/shrink LSP selection range
- `<leader>lD` - Definitions
- `<leader>lt` - Type definitions
- `<leader>li` - Implementations
- `<leader>lr` - References
- `<leader>ls` - Document symbols
- `<leader>lS` - Workspace symbols
- `<leader>ln` - Rename
- `<leader>lh` - Signature help

### Git and GitHub

- `<leader>gn` - Next git hunk
- `<leader>gp` - Previous git hunk
- `<leader>gd` - Diffview for uncommitted changes
- `<leader>gh` - Current file history
- `<leader>gH` - Repository history
- `<leader>gx` - Close Diffview
- `<leader>gio` - Open GitHub issues picker
- `<leader>gpo` - Open GitHub PR picker
- `<leader>gic` - Create GitHub issue with `gh`
- `<leader>gpc` - Create draft PR against `main` with `gh pr create --fill`
- `<leader>gpC` - Prompted PR creation

### Markdown, Quarto, and CriticMarkup

General Markdown mappings:

- `<leader>m1` ... `<leader>m4` - Insert heading 1 to 4
- `<leader>mu` - Unordered list item
- `<leader>mo` - Ordered list item
- `<leader>mt` - Task list item
- Visual `<leader>mb` - Bold
- Visual `<leader>mC` - Inline code
- Visual `<leader>ml` - Link selection with URL from clipboard
- `<leader>mp` - Paste image to `images/`
- `]]` / `[[` - Next/previous heading in Markdown and Quarto

In Markdown/Quarto buffers, buffer-local CriticMarkup mappings override some global visual Markdown mappings:

- Visual `<leader>mi` - `{++insert++}`
- Visual `<leader>md` - `{--delete--}`
- Visual `<leader>mh` - `{==highlight==}`
- Visual `<leader>mc` - `{>>comment<<}`
- Visual `<leader>ms` - `{~~old~>new~~}` with prompt
- Text objects: `ic`/`ac`, `ih`/`ah`, `ii`/`ai`, `id`/`ad`, `ix`/`ax`

CriticMarkup commands:

- `:CriticConvert [format]` - Convert with Pandoc, default `docx`
- `:CriticOpen` - Open last converted DOCX

### Quarto and Slime

- `<C-CR>` - Send current Quarto cell
- `<leader>qa` - Send above
- `<leader>qb` - Send below
- `<leader>qf` - Send whole file
- `<leader>ql` - Send current line to Slime
- `<leader>qr` - Send region to Slime

### Obsidian

- `<leader>on` - New note
- `<leader>oN` - New note from template
- `<leader>od` - Today's daily note
- `<leader>oD` - Daily notes picker
- `<leader>oy` - Yesterday's daily note
- `<leader>ot` - Tomorrow's daily note
- `<leader>of` - Follow link
- `<leader>oo` - Open note in Obsidian app
- `<leader>oq` - Quick switch notes
- `<leader>os` - Search notes
- `<leader>ob` - Backlinks
- `<leader>oL` - Links or create new link from visual selection
- `<leader>ol` - Link visual selection
- `<leader>oe` - Extract visual selection to note
- `<leader>oc` - Toggle checkbox
- `<leader>oi` - Paste image
- `<leader>or` - Rename note
- `<leader>ow` - Switch workspace
- `<leader>oC` - Table of contents
- `<leader>oT` - Tags

Configured workspaces:

- `~/Obsidian/Notes/`
- `~/Obsidian/Personal/`

### References and Citations

- `<leader>rb` - BibTeX citation picker
- `<leader>tR` - Toggle citation command set between Pandoc and LaTeX formats

Default loaded citation commands are Pandoc-oriented, for example `[@key]`, `@key`, `[-@key]`, and page/prefix variants.

### Toggles

- `<leader>ta` - Toggle Aerial outline
- `<leader>tf` - Toggle Aerial nav window
- `<leader>tb` - Toggle current-line blame
- `<leader>tc` - Toggle color highlights
- `<leader>td` - Toggle gitsigns word diff
- `<leader>ti` - Toggle image rendering
- `<leader>tl` - Select project spell language
- `<leader>tm` - Toggle rendered Markdown
- `<leader>tr` - Toggle R language server
- `<leader>ts` - Toggle spell checking
- `<leader>tv` - Toggle CSV view
- `<leader>tw` - Toggle word wrap

## Spell Language Management

Project spell language is stored in `.nvim_spell_lang` at project root. Project root is detected by walking upward to `.git` or `.nvim_spell_lang`.

- `<leader>tl` / `:SpellLang` writes `en_us` or `es` to `.nvim_spell_lang`.
- Buffers default to `en_us` when no project file exists.
- `<leader>ts` toggles spell checking.

## Configuration Structure

```text
.
├── init.lua                      # Main loader
├── lua/
│   ├── theme-config.lua          # Active theme and color values
│   ├── plugins-pack.lua          # vim.pack declarations, eager/opt split
│   ├── plugins-config.lua        # Active plugin, LSP, lazy-load, and theme config
│   ├── core/
│   │   ├── autocommands.lua      # Autocommands and user commands
│   │   ├── critic.lua            # Pandoc CriticMarkup filter
│   │   ├── functions.lua         # Toggles and buffer helpers
│   │   ├── keymaps.lua           # Global keymaps
│   │   ├── llama.lua             # llama.vim setup
│   │   ├── options.lua           # Vim options and diagnostics
│   │   └── pack-mgmt.lua         # vim.pack helper commands
│   └── plugins/                  # Split plugin modules, currently not required by init.lua
├── after/
│   └── ftplugin/
│       ├── markdown.lua          # Markdown options, CriticMarkup maps, Critic commands
│       └── quarto.lua            # Quarto options, sources Markdown ftplugin
├── snippets/                     # Local snippets for blink.cmp/vim.snippet
├── nvim-pack-lock.json           # vim.pack lockfile
└── README.md
```

Load order:

1. Providers disabled, llama config set.
2. `theme-config.lua` read to determine active colorscheme.
3. `plugins-pack.lua` declares/installs eager and opt plugins.
4. Core options, functions, autocommands, and keymaps load.
5. `plugins-config.lua` configures plugins, LSP, and lazy-load hooks.

## Adding Plugins

1. Add plugin spec to `lua/plugins-pack.lua`.
2. Decide eager vs opt.
3. Add setup code to `lua/plugins-config.lua`, or lazy-load setup through filetype/command table.
4. Add keymaps to `lua/core/keymaps.lua` if needed.
5. Restart Neovim or run `:PackSync`.

Minimal eager example:

```lua
table.insert(eager_plugins, { src = "https://github.com/author/plugin-name" })
```

Minimal lazy command example:

```lua
cmd_lazy.PluginCommand = {
  "plugin-name",
  function()
    require("plugin-name").setup({})
  end,
}
```

## Troubleshooting

### Plugins

- `:PackStatus` - inspect plugin state.
- `:PackCheck` - check update availability.
- `:PackDiagnose` - test remotes after fetch failures.
- `:PackClean` then `:PackSync` - refresh declared plugin set.

### LSP

- Confirm external language server exists on `$PATH`.
- Check `:checkhealth vim.lsp`.
- Check filetype with `:set filetype?`.
- Use `<leader>tr` if R LSP needs manual stop/start.

### Formatting

- Confirm formatter executable exists on `$PATH`.
- Use `<leader>cf` to format manually.
- Markdown and Quarto do not format on save by design.

### Documents

- Image rendering starts disabled. Use `<leader>ti`.
- `img-clip.nvim` stores pasted images under `images/` relative to current file.
- `:CriticConvert` requires `pandoc` and the current buffer saved to disk.
- Quarto schema support requires `quarto --paths` to work.

## Design Philosophy

1. Native Neovim first.
2. `vim.pack` over external plugin manager.
3. Eager-load core tools, lazy-load heavier document/data tooling.
4. Strong prose/document workflow: Markdown, Quarto, Obsidian, citations, images, CriticMarkup.
5. External dependencies managed outside Neovim, preferably with Nix.

## License

Provided as-is.
