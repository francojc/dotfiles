-- Import required modules
local wk = require 'which-key'
-- local ms = vim.lsp.protocol.Methods

-- Global variables
P = vim.print
vim.g['quarto_is_r_mode'] = nil
vim.g['reticulate_running'] = false

-- Mode-specific mapping functions
local map_funcs = {
  n = function(key, effect, opts)
    vim.keymap.set('n', key, effect, vim.tbl_extend('force', { silent = true, noremap = true }, opts or {}))
  end,
  x = function(key, effect, opts)
    vim.keymap.set('x', key, effect, vim.tbl_extend('force', { silent = true, noremap = true }, opts or {}))
  end,
  i = function(key, effect, opts)
    vim.keymap.set('i', key, effect, vim.tbl_extend('force', { silent = true, noremap = true }, opts or {}))
  end,
  c = function(key, effect, opts)
    vim.keymap.set('c', key, effect, vim.tbl_extend('force', { silent = true, noremap = true }, opts or {}))
  end,
}

-- Refactored send_cell function
local function send_cell()
  if vim.b['quarto_is_r_mode'] == nil then
    vim.fn['slime#send_cell']()
    return
  end

  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'

    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    elseif not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end

    vim.fn['slime#send_cell']()
  end
end

-- Refactored send_region function
local function send_region()
  local slime_send_region_cmd = ':<C-u>call slime#send_op(visualmode(), 1)<CR>'
  slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)

  if vim.bo.filetype ~= 'quarto' or vim.b['quarto_is_r_mode'] == nil then
    vim.cmd('normal' .. slime_send_region_cmd)
    return
  end

  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'

    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    elseif not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end

    vim.cmd('normal' .. slime_send_region_cmd)
  end
end

-- Language-specific code chunk insertion functions
local insert_chunk = {
  python = function()
    local text = '```{python}\n\n```'
    vim.api.nvim_put(vim.split(text, '\n'), 'l', true, true)
    vim.cmd 'normal! k$'
  end,
  r = function()
    local text = '```{r}\n\n```'
    vim.api.nvim_put(vim.split(text, '\n'), 'l', true, true)
    vim.cmd 'normal! k$'
  end,
  julia = function()
    local text = '```{julia}\n\n```'
    vim.api.nvim_put(vim.split(text, '\n'), 'l', true, true)
    vim.cmd 'normal! k$'
  end,
  lua = function()
    local text = '```{lua}\n\n```'
    vim.api.nvim_put(vim.split(text, '\n'), 'l', true, true)
    vim.cmd 'normal! k$'
  end,
  bash = function()
    local text = '```{bash}\n\n```'
    vim.api.nvim_put(vim.split(text, '\n'), 'l', true, true)
    vim.cmd 'normal! k$'
  end,
}

-- Refactored new_terminal functions
local function new_terminal(direction)
  local terminal_cmd = direction == 'horizontal' and 'split' or 'vsplit'
  vim.cmd(terminal_cmd)
  vim.cmd 'terminal'
  vim.cmd 'startinsert'
end

local function new_terminal_horizontal()
  new_terminal 'horizontal'
end

local function new_terminal_vertical()
  new_terminal 'vertical'
end

-- Helper function to insert a command output
vim.api.nvim_create_user_command('InsertCommandOutput', function()
  vim.ui.input({ prompt = 'Enter command: ' }, function(command)
    if command then
      vim.cmd('read !' .. command)
    end
  end)
end, {})

-- Function to toggle conceallevel
local function toggle_conceallevel()
  if vim.o.conceallevel == 0 then
    vim.o.conceallevel = 1
  else
    vim.o.conceallevel = 0
  end
end

-- Helper function for LSP formatting
local function lsp_format()
  vim.lsp.buf.format { async = true }
end

-- Helper function for toggling line numbers
local function toggle_line_numbers()
  if vim.wo.number then
    vim.wo.number = false
    vim.wo.relativenumber = false
  else
    vim.wo.number = true
    vim.wo.relativenumber = true
  end
end

-- Helper function for toggling wrap
local function toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap
end

local function visual_find_and_replace()
  -- Store the current selection
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"

  -- Prompt for find and replace strings
  local find = vim.fn.input 'Find: '
  local replace = vim.fn.input 'Replace: '

  -- Perform the substitution on the selected text
  vim.cmd(string.format('%d,%ds/%s/%s/g', start_pos[2], end_pos[2], find, replace))
end

local function toggle_theme_color()
  if vim.o.background == 'light' then
    vim.o.background = 'dark'
  else
    vim.o.background = 'light'
  end
end

-- Function to add blank lines and enter insert mode
local function add_blank_lines_and_insert()
  vim.cmd 'normal! O' -- Add blank line above
  vim.cmd 'normal! jo' -- Add blank line below and move cursor to it
  vim.cmd 'normal! k' -- Move cursor back to the original line
  vim.cmd 'startinsert' -- Enter insert mode
end

-- Function to toggle apple-music functionality
local function toggle_play_music()
  require('apple-music').toggle_play()
end

local function toggle_shuffle_music()
  require('apple-music').toggle_shuffle()
end

-- Which-Key mappings
wk.add {
  { '<leader>a', group = 'Apple Music' },
  {
    '<leader>ap',
    function()
      require('apple-music').select_playlist_telescope()
    end,
    desc = 'Find playlists',
  },
  {
    '<leader>aa',
    function()
      require('apple-music').select_album_telescope()
    end,
    desc = 'Find albums',
  },
  {
    '<leader>as',
    function()
      require('apple-music').select_track_telescope()
    end,
    desc = 'Find songs',
  },
  {
    '<leader>ax',
    function()
      require('apple-music').cleanup_all()
    end,
    desc = 'Cleanup temp playlists',
  },

  -- Buffer operations
  { '<leader>b', name = 'Buffer' },
  { '<leader>bb', '<cmd>Telescope buffers<cr>', desc = 'Switch Buffer' },
  { '<leader>bd', '<cmd>bdelete<cr>', desc = 'Delete Buffer' },
  { '<leader>bn', '<cmd>bnext<cr>', desc = 'Next Buffer' },
  { '<leader>bp', '<cmd>bprevious<cr>', desc = 'Previous Buffer' },

  -- Code execution
  { '<leader>c', name = 'Code' },
  { '<leader>cc', send_cell, desc = 'Send Cell' },
  { '<leader>cr', send_region, desc = 'Send Region' },

  -- Debug operations
  { '<leader>d', name = 'Debug' },
  { '<leader>dt', name = 'Tests' },

  -- Editor operations
  { '<leader>e', name = 'Editor' },

  -- File operations
  { '<leader>f', group = 'File' },
  { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find File' },
  { '<leader>fr', '<cmd>Telescope oldfiles<cr>', desc = 'Open Recent File' },
  { '<leader>fn', '<cmd>enew<cr>', desc = 'New File' },
  { '<leader>fs', '<cmd>w<cr>', desc = 'Save File' },

  -- Git operations
  { '<leader>g', name = 'Git' },
  { '<leader>gc', '<cmd>Telescope git_commits<cr>', desc = 'Git Commits' },
  { '<leader>gs', '<cmd>Telescope git_status<cr>', desc = 'Git Status' },
  { '<leader>gt', '<cmd>Telescope git_branches<cr>', desc = 'Git Branches' },
  { '<leader>go', '<cmd>Octo actions<cr>', desc = 'Open Octo actions' },

  -- Help
  { '<leader>h', name = 'Help' },
  { '<leader>hv', '<cmd>Telescope vim_options<cr>', desc = '[V]im Options' },
  { '<leader>hk', '<cmd>Telescope keymaps<cr>', desc = 'Search [K]eymaps' },
  { '<leader>hh', '<cmd>Telescope help_tags<cr>', desc = 'Search [H]elp Tags' },
  { '<leader>hc', '<cmd>CodeCompanionActions<cr>', desc = 'Open [C]odeCompanion' },
  { '<leader>hq', '<cmd>QuartoHelp<cr>', desc = '[Q]uarto Help' },

  -- Insert operations
  { '<leader>i', name = 'Insert' },
  { '<leader>il', add_blank_lines_and_insert, desc = 'Insert Blank Lines' },
  { '<leader>ic', '<cmd>InsertCommandOutput<cr>', desc = '(Insert Command Output)' },

  -- LSP operations
  { '<leader>l', name = 'LSP' },
  { '<leader>lf', lsp_format, desc = 'Format' },
  { '<leader>lr', vim.lsp.buf.rename, desc = 'Rename' },
  { '<leader>la', vim.lsp.buf.code_action, desc = 'Code Action' },
  { '<leader>ld', vim.lsp.buf.definition, desc = 'Go to Definition' },
  { '<leader>li', vim.lsp.buf.implementation, desc = 'Go to Implementation' },
  { '<leader>lh', vim.lsp.buf.hover, desc = 'Hover Documentation' },

  -- Obsidian operations
  { '<leader>n', name = 'Obsidian' },

  -- Quarto operations
  { '<leader>q', name = 'Quarto' },
  { '<leader>qa', '<cmd>QuartoActivate<cr>', desc = 'Activate' },
  { '<leader>qp', "<cmd>lua require'quarto'.quartoPreview()<cr>", desc = 'Preview' },
  { '<leader>qq', "<cmd>lua require'quarto'.quartoClosePreview()<cr>", desc = 'Close Preview' },
  { '<leader>qh', '<cmd>QuartoHelp<cr>', desc = 'Help' },
  { '<leader>qe', "<cmd>lua require'otter'.export()<cr>", desc = 'Export' },
  { '<leader>qE', "<cmd>lua require'otter'.export(true)<cr>", desc = 'Export Overwrite' },
  { '<leader>qr', name = 'Run' },
  { '<leader>qrr', '<cmd>QuartoSend<cr>', desc = 'Run Current' },
  { '<leader>qra', '<cmd>QuartoSendAbove<cr>', desc = 'Run Above' },

  -- Search operations
  { '<leader>s', name = 'Search' },
  { '<leader>sf', '<cmd>Telescope live_grep<cr>', desc = 'Find Text' },
  { '<leader>sg', name = 'Grug' },
  { '<leader>sgo', '<cmd>GrugFar<cr>', desc = 'Open' },
  { '<leader>sc', '<cmd>Telescope commands<cr>', desc = 'Commands' },
  { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Todos' },

  -- Terminal operations
  { '<leader>t', name = 'Terminal' },
  { '<leader>th', new_terminal_horizontal, desc = 'New Horizontal Terminal' },
  { '<leader>tv', new_terminal_vertical, desc = 'New Vertical Terminal' },

  -- Vim operations
  { '<leader>v', name = 'Vim' },
  { '<leader>vc', '<cmd>Telescope colorscheme<cr>', desc = 'View and select colorscheme' },
  { '<leader>vl', '<cmd>Lazy<cr>', desc = 'Lazy plugin manager' },
  { '<leader>vm', '<cmd>Mason<cr>', desc = 'Mason software installer' },

  -- Yazi operations
  { '<leader>y', name = 'Yazi' },
  { '<leader>yd', yazi_change_dir, desc = '(Select new CWD)' },

  -- Toggle operations
  { '<leader>\\', name = 'Toggle' },
  { '<leader>\\a', '<cmd>CodeCompanionToggle<cr>', desc = 'Toggle Assistant' },
  { '<leader>\\d', '<cmd>TodoQuickFix<cr>', desc = 'Toggle Todos' },
  { '<leader>\\h', toggle_conceallevel, desc = 'Toggle Conceal Level' },
  { '<leader>\\n', toggle_line_numbers, desc = 'Toggle Line Numbers' },
  { '<leader>\\o', '<cmd>AerialToggle<cr>', desc = 'Toggle Aerial Outline' },
  { '<leader>\\p', toggle_play_music, desc = 'Toggle Music Playback' },
  { '<leader>\\s', toggle_shuffle_music, desc = 'Toggle Music Shuffle' },
  { '<leader>\\t', toggle_theme_color, desc = 'Toggle Light/Dark Theme' },
  { '<leader>\\w', toggle_wrap, desc = 'Toggle Wrap' },

  -- Visual mode mappings
  {
    mode = 'x',
    -- Code
    { '<leader>c', name = 'Send Code' },
    { '<leader>cr', send_region, desc = 'Send Region' },
    -- Find and Replace
    { '<leader>r', name = 'Find/Replace' },
    { '<leader>rr', visual_find_and_replace, desc = 'Find and Replace' },
    -- Wrap operations
    { '<leader>w', name = 'Wrap Selection' },
    { '<leader>wb', 'c**<Esc>pa**<Esc>', desc = 'Wrap bold' },
    { '<leader>wi', 'c*<Esc>pa*<Esc>', desc = 'Wrap italic' },
    { '<leader>ws', 'c~~<Esc>pa~~<Esc>', desc = 'Wrap strikethrough' },
    { '<leader>wm', 'c$<Esc>pa$<Esc>', desc = 'Wrap math' },
  },

  -- Normal/ Insert mode mappings
  {
    mode = { 'n', 'i' },
    { '<M-->', ' <- ', desc = 'Assignment operator' },
    { '<M-p>', ' |> ', desc = 'Pipe operator (native)' },
    { '<M-m>', ' %>% ', desc = 'Pipe operator (magrittr)' },
    { '<M-;>', ' :: ', desc = 'Namespace' },

    { '<M-i>', name = 'Insert Chunk' },
    { '<M-i>p', insert_chunk.python, desc = 'Python Chunk' },
    { '<M-i>r', insert_chunk.r, desc = 'R Chunk' },
    { '<M-i>j', insert_chunk.julia, desc = 'Julia Chunk' },
    { '<M-i>l', insert_chunk.lua, desc = 'Lua Chunk' },
    { '<M-i>b', insert_chunk.bash, desc = 'Bash Chunk' },
  },
}

-- Additional non-Which-Key mappings
local function set_additional_mappings()
  -- Normal mode mappings
  map_funcs.n('<leader>,', '<cmd>Alpha<cr>', { desc = 'Home' })
  map_funcs.n('j', "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = 'Down by visual lines' })
  map_funcs.n('k', "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = 'Up by visual lines' })
  map_funcs.n('<C-h>', '<C-w>h', { desc = 'Move to the left window' })
  map_funcs.n('<C-j>', '<C-w>j', { desc = 'Move to the bottom window' })
  map_funcs.n('<C-k>', '<C-w>k', { desc = 'Move to the top window' })
  map_funcs.n('<C-l>', '<C-w>l', { desc = 'Move to the right window' })
  map_funcs.n('H', '<cmd>tabp<cr>', { desc = 'Previous Tab' })
  map_funcs.n('L', '<cmd>tabn<cr>', { desc = 'Next Tab' })
  map_funcs.n('<c-d>', '<c-d>zz', { desc = 'Scroll down half page' })
  map_funcs.n('<c-u>', '<c-u>zz', { desc = 'Scroll up half page' })
  map_funcs.n('<esc>', '<cmd>noh<cr>', { desc = 'Clear Search Highlighting' })
  map_funcs.n('z?', 'setlocal spell!', { desc = 'Toggle Spell Check' })
  map_funcs.n('<c-cr>', '<Plug>SlimeParagraphSend<cr>', { desc = 'Send code phrase' })
  map_funcs.n('<s-cr>', '<cmd>SlimeSend1<cr>', { desc = 'Send code block' })

  -- Insert mode mappings
  map_funcs.i('jj', '<Esc>')

  -- Visual mode mappings
  map_funcs.x('<', '<gv', { desc = 'Unindent' })
  map_funcs.x('>', '>gv', { desc = 'Indent' })
  map_funcs.x('J', ":m '>+1<cr>gv=gv", { desc = 'Move line down' })
  map_funcs.x('K', ":m '<-2<cr>gv=gv", { desc = 'Move line up' })
  map_funcs.x('<cr>', send_region, { desc = 'Send Region' })
end

-- Call the function to set additional mappings
set_additional_mappings()
