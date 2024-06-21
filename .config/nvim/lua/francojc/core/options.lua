-- add tree-like file explorer
vim.cmd("let g:netrw_liststyle = 3")

-- vim slime target 
vim.cmd("let g:slime_target = 'tmux'")
vim.cmd("let g:slime_default_config = {'socket_name': 'default', 'target_pane': '2'}")
vim.cmd("let g:slime_dont_ask_default = 0")
-- code block defined (see keymaps.lua)
vim.cmd("let g:slime_cell_delimiter = '```'")

-- numbers and cursor view
local opt = vim.opt
opt.relativenumber = true -- add numbers relative to current position
opt.number = true -- add current line number
opt.cursorline = false -- highlight current line

--- wrap text 
opt.wrap = true
opt.wrapmargin = 2

-- tabs and indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- linebreak for long lines
opt.linebreak = true
opt.breakindent = true

-- textwidth for given file types
vim.api.nvim_create_augroup("SetTextWidth", { clear = true })

-- Set textwidth function
local function set_textwidth(textwidth)
  vim.opt_local.textwidth = textwidth
  vim.opt_local.colorcolumn = tostring(textwidth)
end

vim.api.nvim_create_autocmd("FileType", {
  group = "SetTextWidth",
  pattern = {"r"},
  callback = function() set_textwidth(80) end
})

-- search settings
opt.ignorecase = true -- ignore case in searches
opt.smartcase = true -- with mixed-case search, case-sensitive enabled

-- spelling
opt.spell = true
opt.spelllang = "en_us"
opt.spellfile = "/Users/francojc/.config/nvim/spell/en.utf-8.add"

-- turn on termguicolors
-- opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent

-- clipboard
opt.clipboard:append("unnamedplus") --use system clipboard

-- complete options
opt.completeopt = {'menu', 'menuone', 'noselect'}

-- mouse
opt.mouse = "a"

-- split windows
opt.splitright = true
opt.splitbelow = true

-- turn off swapfile
opt.swapfile = false

-- LSP configurations
-- Copilot colorscheme
local augroup = vim.api.nvim_create_augroup("CopilotColorscheme", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "tokyonight",
  group = augroup,
  callback = function()
    vim.api.nvim_set_hl(0, "CopilotSuggestion", {
      fg = "grey", -- Light blue
      -- bg = "#1A1B26", -- Dark Background
      ctermfg = 8,
      italic = true,
      force = true
    })
  end
})

-- Enable spell checking for given file types
-- Enable spell checking by default for text files
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"text", "markdown", "quarto", "gitcommit"},
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end
})
