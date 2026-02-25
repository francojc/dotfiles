-- Neovim 0.12+ Ultra-Stock Configuration
-- Pure built-in features, zero external plugins

-- Settings ------------------------------------------------------------

-- Line numbers & cursor
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- Display & UI
vim.opt.termguicolors = true
vim.cmd("colorscheme retrobox")
vim.opt.mouse = "a"
vim.opt.signcolumn = "yes:1"
vim.opt.background = "dark"
vim.opt.fillchars = "foldinner: "
vim.opt.winborder = "rounded"

-- Statusline & command line
vim.opt.showmode = false
vim.opt.showcmd = true
vim.opt.ruler = true
vim.opt.laststatus = 2
vim.opt.cmdheight = 1

-- Wrapping
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "

-- Scrolling
vim.opt.scrolloff = 2
vim.opt.sidescrolloff = 5

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.inccommand = "split"
vim.opt.maxsearchcount = 999

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Files & backup
vim.opt.clipboard:append("unnamedplus")
vim.opt.path:append("**")
vim.opt.autoread = true
vim.opt.autowriteall = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Timing
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10

-- Completion
vim.opt.autocomplete = true
vim.opt.complete = ".,w,b,u,t,i,kspell,F,o"
vim.opt.completeopt = "menu,menuone,preview,noselect,nearest"
vim.opt.pummaxwidth = 60

-- Wildmenu
vim.opt.wildchar = 9
vim.opt.wildmode = "full:longest,full:longest,list:longest"

-- Diff
vim.opt.diffopt = "indent-heuristic,inline:char"

-- Plugins -------------------------------------------------------------

vim.pack.add({
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
})

-- Plugin configuration ---------------------------------------

-- Plugin Management Structure (ready for future plugins)

local pack_path = vim.fn.stdpath('data') .. '/site/pack'
vim.opt.packpath:prepend(pack_path)

-- LSP Configuration (Key 0.12 Features)
-- Enable LSP with simplified setup
vim.lsp.enable({
  "lua_ls",
  "pyright",
  "tsserver",
  "rust_analyzer"
})

-- Configure LSP settings
vim.lsp.config("lua_ls", {
  workspace_required = true,
  root_markers = {".luarc.json", ".luacheckrc", ".git"},
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT"
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true)
      }
    }
  }
})

-- Selection range mappings (0.12 feature)
vim.keymap.set("x", "an", function()
  vim.lsp.buf.selection_range(1)
end, { desc = "Select outward" })

vim.keymap.set("x", "in", function()
  vim.lsp.buf.selection_range(-1)
end, { desc = "Select inward" })

-- Type definition mapping (new 0.12 mapping)
vim.keymap.set("n", "grt", vim.lsp.buf.type_definition, { desc = "Type definition" })

-- Editor Enhancements
-- Treesitter setup (wrapped in autocommand to ensure buffer context)
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  callback = function(args)
    local ok = pcall(vim.treesitter.start, args.buf)
    if not ok then
      -- Silently fail if treesitter parser not available
    end
  end
})

-- Statusline Configuration
vim.opt.statusline = "%!v:lua.require'my_statusline'.active()"
-- Create statusline module
local function create_statusline_module()
  local M = {}
  
  function M.active()
    local parts = {}
    
    -- Mode
    table.insert(parts, string.format("%%-5(%s%%)", vim.fn.mode(1)))
    
    -- File info
    table.insert(parts, " %f")
    
    -- Modified flag
    if vim.bo.modified then
      table.insert(parts, " [+]")
    end
    
    -- Readonly flag
    if vim.bo.readonly then
      table.insert(parts, " [RO]")
    end
    
    -- Diagnostics
    local diagnostics = vim.diagnostic.status()
    if diagnostics then
      table.insert(parts, " " .. diagnostics)
    end
    
    -- Busy indicator
    if vim.bo.busy then
      table.insert(parts, " ◐")
    end
    
    -- Position
    table.insert(parts, " %=%l:%c %P")
    
    return table.concat(parts, "")
  end
  
  return M
end

-- Register statusline module
package.loaded.my_statusline = create_statusline_module()

-- Key Mappings (0.12 Features)
-- URL opening (enhanced in 0.12)
vim.keymap.set("n", "gx", function()
  local url = vim.fn.expand("<cWORD>")
  if url:match("^https?://") then
    vim.ui.open(url)
  end
end, { desc = "Open URL under cursor" })

-- Autocommands & Cleanup
local augroup = vim.api.nvim_create_augroup("MyConfig", { clear = true })

-- FileType-specific settings
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "lua", "python", "typescript", "rust" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end
})

-- Terminal configuration
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end
})

-- Health check customization
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "checkhealth",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end
})

-- Handle 0.12 breaking changes
-- Diagnostic signs (no longer use sign_define)
vim.diagnostic.config({
  signs = true,
  underline = true,
  virtual_text = true,
  virtual_lines = {
    current_line = true,
  },
  update_in_insert = false
})

-- vim.diff renamed to vim.text.diff
vim.text = vim.text or {}
vim.text.diff = vim.diff

-- LSP selection_range now accepts integer
-- Already handled in mappings above

-- UI messages changes
-- msg_show.return_prompt removed - no action needed

-- Print configuration loaded message
vim.notify("Neovim 0.12+ Ultra-Stock Configuration loaded", vim.log.levels.INFO)
