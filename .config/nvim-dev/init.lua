-- =============================================================================
-- Neovim 0.12 Minimalist Configuration
-- =============================================================================

-- =============================================================================
-- 1. CORE EDITOR SETTINGS
-- =============================================================================

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true

-- Language-specific indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- UI
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.colorcolumn = "80"

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Undo
vim.opt.undofile = true
vim.opt.undolevels = 10000

-- Performance
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Misc
vim.opt.mouse = "a"
vim.opt.showmode = false

-- =============================================================================
-- 2. NEW NVIM 0.12 FEATURES
-- =============================================================================

-- Built-in auto-completion (NEW in 0.12!)
vim.opt.autocomplete = true

-- Fuzzy completion collection (NEW in 0.12!)
-- Enable fuzzy matching for keyword completion
vim.opt.completefuzzycollect = "keyword"

-- Completion options with distance-based sorting (NEW in 0.12!)
vim.opt.completeopt = "menu,menuone,noselect,nearest"

-- Popup menu border (NEW in 0.12!)
vim.opt.pumborder = "single"

-- Maximum popup menu width (NEW in 0.12!)
vim.opt.pummaxwidth = 60

-- =============================================================================
-- 3. PLUGIN MANAGEMENT WITH VIM.PACK (NEW IN 0.12!)
-- =============================================================================

-- Helper function to install plugins using vim.pack
local function install_plugin(url, name)
  local install_path = vim.fn.stdpath("data") .. "/site/pack/plugins/start/" .. name

  if vim.fn.isdirectory(install_path) == 0 then
    print("Installing " .. name .. "...")
    vim.fn.system({
      "git",
      "clone",
      "--depth=1",
      url,
      install_path,
    })
    vim.cmd("packloadall")
    return true
  end
  return false
end

-- Install plugins
local plugins_installed = false

plugins_installed = install_plugin("https://github.com/folke/tokyonight.nvim", "tokyonight.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/nvim-lua/plenary.nvim", "plenary.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/nvim-treesitter/nvim-treesitter", "nvim-treesitter") or plugins_installed
plugins_installed = install_plugin("https://github.com/ibhagwan/fzf-lua", "fzf-lua") or plugins_installed
plugins_installed = install_plugin("https://github.com/mikavilpas/yazi.nvim", "yazi.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/lewis6991/gitsigns.nvim", "gitsigns.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/nvim-lualine/lualine.nvim", "lualine.nvim") or plugins_installed
plugins_installed = install_plugin("https://github.com/L3MON4D3/LuaSnip", "LuaSnip") or plugins_installed

-- Reload config if plugins were just installed
if plugins_installed then
  print("Plugins installed. Please restart Neovim.")
end

-- =============================================================================
-- 4. PLUGIN CONFIGURATION
-- =============================================================================

-- Colorscheme: Tokyonight
pcall(function()
  require("tokyonight").setup({
    style = "night",
    transparent = false,
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
    },
  })
  vim.cmd.colorscheme("tokyonight")
end)

-- Gitsigns
pcall(function()
  require("gitsigns").setup({
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },
    current_line_blame = false,
  })
end)

-- Lualine (status line)
pcall(function()
  require("lualine").setup({
    options = {
      theme = "tokyonight",
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff" },
      lualine_c = { "filename" },
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_lsp" },
          symbols = { error = " ", warn = " ", info = " ", hint = " " },
        },
        "encoding",
        "fileformat",
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  })
end)

-- FzfLua
pcall(function()
  require("fzf-lua").setup({
    winopts = {
      border = "single",
      preview = {
        border = "single",
      },
    },
  })
end)

-- Yazi
pcall(function()
  require("yazi").setup({
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
  })
end)

-- LuaSnip
pcall(function()
  require("luasnip").setup({
    history = true,
    updateevents = "TextChanged,TextChangedI",
  })
end)

-- =============================================================================
-- 5. LSP CONFIGURATION
-- =============================================================================

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "single",
    source = "if_many",
  },
})

-- Diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- LSP on_attach function
local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- LSP key mappings
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "grt", vim.lsp.buf.type_definition, opts) -- NEW in 0.12!
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)

  -- Incremental selection (NEW in 0.12!)
  vim.keymap.set("n", "an", vim.lsp.buf.selection_range, opts)
end

-- Configure language servers using new vim.lsp.config API (0.12+)

-- R Language Server
vim.lsp.config("r_language_server", {
  cmd = { "R", "--slave", "-e", "languageserver::run()" },
  filetypes = { "r", "rmd" },
  root_markers = { ".git", "DESCRIPTION", ".Rproj.user" },
  on_attach = on_attach,
  settings = {
    r = {
      lsp = {
        diagnostics = true,
      },
    },
  },
})

-- TypeScript/JavaScript
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  on_attach = on_attach,
})

-- Lua
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

-- Bash
vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" },
  root_markers = { ".git" },
  on_attach = on_attach,
})

-- Nix
vim.lsp.config("nil_ls", {
  cmd = { "nil" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", "default.nix", ".git" },
  on_attach = on_attach,
  settings = {
    ["nil"] = {
      formatting = {
        command = { "nixpkgs-fmt" },
      },
    },
  },
})

-- Enable language servers for their respective filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "rmd", "javascript", "javascriptreact", "typescript", "typescriptreact", "lua", "sh", "bash", "nix" },
  callback = function(args)
    local server_map = {
      r = "r_language_server",
      rmd = "r_language_server",
      javascript = "ts_ls",
      javascriptreact = "ts_ls",
      typescript = "ts_ls",
      typescriptreact = "ts_ls",
      lua = "lua_ls",
      sh = "bashls",
      bash = "bashls",
      nix = "nil_ls",
    }
    local server = server_map[vim.bo[args.buf].filetype]
    if server then
      vim.lsp.enable(server)
    end
  end,
})

-- =============================================================================
-- 6. TREESITTER CONFIGURATION
-- =============================================================================

pcall(function()
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "r",
      "javascript",
      "typescript",
      "tsx",
      "lua",
      "bash",
      "nix",
      "markdown",
      "markdown_inline",
      "html",
      "css",
      "json",
      "yaml",
    },
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        scope_incremental = "<S-CR>",
        node_decremental = "<BS>",
      },
    },
  })

  -- Enable folding based on treesitter
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldenable = false -- Don't fold by default
end)

-- =============================================================================
-- 7. KEY MAPPINGS
-- =============================================================================

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Resize windows
vim.keymap.set("n", "<C-Up>", "<cmd>resize -2<CR>")
vim.keymap.set("n", "<C-Down>", "<cmd>resize +2<CR>")
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- Buffer navigation
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>")
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>")
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>")

-- Move lines
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<CR>==")
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<CR>==")
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- Better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Diagnostic navigation
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- FzfLua mappings
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>")
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>")
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<CR>")
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>")
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua lsp_references<CR>")
vim.keymap.set("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>")

-- Yazi file explorer
vim.keymap.set("n", "<leader>e", "<cmd>Yazi<CR>")

-- Quick save and quit
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>")

-- =============================================================================
-- 8. UI AND AESTHETICS
-- =============================================================================

-- Use new 0.12 highlight groups for enhanced diff
vim.api.nvim_set_hl(0, "DiffTextAdd", { bg = "#3d5213", fg = "#b4fa72" })

-- Enhanced popup menu appearance with new 0.12 highlights
vim.api.nvim_set_hl(0, "PmenuBorder", { fg = "#7aa2f7" })

-- =============================================================================
-- AUTOCMDS
-- =============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Auto-create directories when saving
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- =============================================================================
-- END OF CONFIGURATION
-- =============================================================================
