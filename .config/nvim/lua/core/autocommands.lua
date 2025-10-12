--| Autocommands -------------------------------------------------
local a = vim.api

-- Create an autocommand group
-- personal group
a.nvim_create_augroup("personal", { clear = true })

-- Remove trailing whitespace on save
a.nvim_create_autocmd("BufWritePre", {
  group = "personal",
  pattern = "*",
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- Highlight on yank
a.nvim_create_autocmd("TextYankPost", {
  group = "personal",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Ensure .qmd files are treated as markdown for navigation and features
a.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = "personal",
  pattern = "*.qmd",
  callback = function()
    -- Set filetype to quarto but ensure markdown features work
    vim.bo.filetype = "quarto"
    -- Enable markdown-like navigation
    vim.bo.define = "^\\s*#\\+\\s*"
  end,
})

-- Simple markdown/quarto heading navigation
a.nvim_create_autocmd("FileType", {
  group = "personal",
  pattern = { "markdown", "quarto" },
  callback = function()
    -- Basic ]] and [[ navigation for headings
    vim.keymap.set(
      "n",
      "]]",
      "/^#\\+\\s.*$<CR>:nohlsearch<CR>",
      { buffer = true, silent = true, desc = "Next heading" }
    )
    vim.keymap.set(
      "n",
      "[[",
      "?^#\\+\\s.*$<CR>:nohlsearch<CR>",
      { buffer = true, silent = true, desc = "Previous heading" }
    )
  end,
})

-- Auto-activate otter for Quarto files
a.nvim_create_autocmd("FileType", {
  group = "personal",
  pattern = "quarto",
  callback = function()
    require("otter").activate()
  end,
})

-- Slime cell delimiter for R, Quarto, Markdown
vim.api.nvim_create_autocmd("FileType", {
  -- limit to only certain filetypes
  pattern = { "r", "quarto", "markdown" },
  callback = function()
    vim.b.slime_cell_delimiter = "```"
  end,
})

-- Session management: auto-save on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local session_dir = vim.fn.stdpath("state") .. "/sessions"
    if vim.fn.isdirectory(session_dir) == 0 then
      vim.fn.mkdir(session_dir, "p")
    end
    local target = session_dir .. "/last.vim"
    pcall(vim.cmd, "mksession! " .. vim.fn.fnameescape(target))
  end,
})

-- Spell language management
local function get_project_root()
  local current_file = vim.fn.expand("%:p")
  if current_file == "" then
    return nil
  end
  local path = vim.fn.fnamemodify(current_file, ":h")
  while path ~= "" and path ~= "/" do
    if vim.fn.isdirectory(path .. "/.git") == 1 or vim.fn.isdirectory(path .. "/.nvim_spell_lang") == 1 then
      return path
    end
    path = vim.fn.fnamemodify(path, ":h")
  end
  return nil
end

local function load_spell_lang()
  local project_root = get_project_root()
  if not project_root then
    return
  end
  local spell_lang_file = project_root .. "/.nvim_spell_lang"
  if vim.fn.filereadable(spell_lang_file) == 1 then
    local lang = vim.trim(vim.fn.readfile(spell_lang_file)[1])
    vim.opt_local.spelllang = lang
  else
    vim.opt_local.spelllang = "en_us"
  end
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    load_spell_lang()
  end,
})

-- Spell language command
local function set_spell_lang(lang)
  local project_root = get_project_root()
  if not project_root then
    return
  end
  local spell_lang_file = project_root .. "/.nvim_spell_lang"
  vim.fn.writefile({ lang }, spell_lang_file)
  vim.opt_local.spelllang = lang
end

vim.api.nvim_create_user_command("SpellLang", function()
  vim.ui.select({ "en_us", "es" }, {
    prompt = "Select spell language:",
  }, function(choice)
    if choice then
      set_spell_lang(choice)
    end
  end)
end, {})
