-- Helper Functions for Neovim 0.11.x

local M = {}

-- Map function (exported for keymaps module)
function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  if type(mode) == 'table' then
    for _, m in ipairs(mode) do
      vim.api.nvim_set_keymap(m, lhs, rhs, options)
    end
  else
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
  end
end

-- Statusline helpers
function _G.Get_mode_name()
  local mode = vim.api.nvim_get_mode().mode
  local mode_names = {
    n = 'NORMAL',
    i = 'INSERT',
    v = 'VISUAL',
    V = 'V-LINE',
    ['\x16'] = 'V-BLOCK',
    c = 'COMMAND',
    t = 'TERMINAL',
  }
  return mode_names[mode] or string.upper(mode)
end

function _G.Get_git_branch()
  local branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('\n', '')
  if branch ~= '' then
    return '  ' .. branch .. ' '
  end
  return ''
end

-- 0.11-compatible diagnostic status (replaces vim.diagnostic.status)
function _G.Get_diagnostic_status()
  local bufnr = vim.api.nvim_get_current_buf()
  local counts = { 0, 0, 0, 0 }
  for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
    counts[diagnostic.severity] = counts[diagnostic.severity] + 1
  end

  local parts = {}
  if counts[vim.diagnostic.severity.ERROR] > 0 then
    table.insert(parts, 'E:' .. counts[vim.diagnostic.severity.ERROR])
  end
  if counts[vim.diagnostic.severity.WARN] > 0 then
    table.insert(parts, 'W:' .. counts[vim.diagnostic.severity.WARN])
  end
  if counts[vim.diagnostic.severity.INFO] > 0 then
    table.insert(parts, 'I:' .. counts[vim.diagnostic.severity.INFO])
  end
  if counts[vim.diagnostic.severity.HINT] > 0 then
    table.insert(parts, 'H:' .. counts[vim.diagnostic.severity.HINT])
  end

  if #parts > 0 then
    return ' ' .. table.concat(parts, ' ') .. ' '
  end
  return ''
end

function _G.Get_search_count()
  if vim.v.hlsearch == 0 then
    return ''
  end
  local ok, result = pcall(vim.fn.searchcount, { recompute = 1 })
  if not ok or result.total == 0 then
    return ''
  end
  return string.format(' [%d/%d] ', result.current, result.total)
end

-- Buffer management
function _G.Close_other_buffers()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_buf_delete(buf, { force = false })
    end
  end
end

-- Toggle functions
local spell_enabled = false
function _G.Toggle_spell()
  spell_enabled = not spell_enabled
  vim.opt.spell = spell_enabled
  vim.notify('Spell: ' .. (spell_enabled and 'on' or 'off'))
end

local wrap_enabled = true
function _G.Toggle_wrap()
  wrap_enabled = not wrap_enabled
  vim.opt.wrap = wrap_enabled
  vim.notify('Wrap: ' .. (wrap_enabled and 'on' or 'off'))
end

local image_rendering_enabled = true
function _G.Toggle_image_rendering()
  image_rendering_enabled = not image_rendering_enabled
  if _G.Snacks_image_toggle then
    _G.Snacks_image_toggle(image_rendering_enabled)
  end
  vim.notify('Image rendering: ' .. (image_rendering_enabled and 'on' or 'off'))
end

-- Copilot model presets
local copilot_presets = {
  academic = { model = 'gpt-4', temperature = 0.2 },
  creative = { model = 'gpt-4', temperature = 0.8 },
  precise = { model = 'gpt-4o', temperature = 0.1 },
  research = { model = 'o1-preview', temperature = 0.3 },
  code = { model = 'gpt-4o', temperature = 0.2 },
}

function _G.Copilot_set_model_preset(preset_name)
  local preset = copilot_presets[preset_name]
  if preset then
    vim.g.copilot_chat_model = preset.model
    vim.notify('Copilot model: ' .. preset_name .. ' (' .. preset.model .. ')')
  end
end

function _G.Copilot_toggle_model_preset()
  vim.ui.select(vim.tbl_keys(copilot_presets), {
    prompt = 'Select Copilot model preset:',
  }, function(choice)
    if choice then
      _G.Copilot_set_model_preset(choice)
    end
  end)
end

-- Session management
function _G.Session_save_prompt()
  vim.ui.input({ prompt = 'Session name: ' }, function(name)
    if name and name ~= '' then
      vim.cmd('mksession! ~/.vim/sessions/' .. name .. '.vim')
      vim.notify('Session saved: ' .. name)
    end
  end)
end

function _G.Session_load_last()
  local sessions = vim.fn.glob('~/.vim/sessions/*.vim', false, true)
  if #sessions > 0 then
    vim.cmd('source ' .. sessions[1])
    vim.notify('Loaded session: ' .. vim.fn.fnamemodify(sessions[1], ':t:r'))
  else
    vim.notify('No sessions found')
  end
end

function _G.Session_select()
  local sessions = vim.fn.glob('~/.vim/sessions/*.vim', false, true)
  if #sessions == 0 then
    vim.notify('No sessions found')
    return
  end

  local names = {}
  for _, session in ipairs(sessions) do
    table.insert(names, vim.fn.fnamemodify(session, ':t:r'))
  end

  vim.ui.select(names, { prompt = 'Load session:' }, function(choice)
    if choice then
      vim.cmd('source ~/.vim/sessions/' .. choice .. '.vim')
      vim.notify('Loaded session: ' .. choice)
    end
  end)
end

-- Citation format toggle
local citation_pandoc = true
function _G.Toggle_citation_format()
  citation_pandoc = not citation_pandoc
  vim.notify('Citation format: ' .. (citation_pandoc and 'Pandoc' or 'LaTeX'))
end

-- R LSP toggle
local r_lsp_enabled = false
function _G.Toggle_r_language_server()
  r_lsp_enabled = not r_lsp_enabled
  if r_lsp_enabled then
    vim.cmd('LspStart r_language_server')
    vim.notify('R LSP: enabled')
  else
    vim.cmd('LspStop r_language_server')
    vim.notify('R LSP: disabled')
  end
end

return M
