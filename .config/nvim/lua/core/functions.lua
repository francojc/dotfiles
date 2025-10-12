---| Functions --------------------------------------------

-- Custom Todo Search with Filetype Filtering
function _G.TodoSearchFzfLua()
  -- Configure which filetypes to EXCLUDE from todo search
  -- Modify this table to add filetypes you want to exclude
  local disallowed_filetypes = {
    "json",
  }

  -- Create exclusion pattern for ripgrep
  local exclusions = {}
  for _, filetype in ipairs(disallowed_filetypes) do
    table.insert(exclusions, "--glob '!*." .. filetype .. "'")
  end

  -- Add additional common exclusions
  table.insert(exclusions, "--glob '!.git/*'")
  table.insert(exclusions, "--glob '!node_modules/*'")
  table.insert(exclusions, "--glob '!.DS_Store'")
  table.insert(exclusions, "--glob '!.tags'")

  local rg_opts = table.concat(exclusions, " ") .. " --hidden --line-number --column"

  -- Call TodoFzfLua with custom ripgrep options to filter by filetype
  require("todo-comments.fzf").todo({
    cwd = vim.fn.getcwd(),
    rg_opts = rg_opts,
    silent = true, -- Hide FZF-lua warning messages
  })
end

-- Session management helpers using core session commands
local session_dir = vim.fn.stdpath("state") .. "/sessions"

local function ensure_session_dir()
  if vim.fn.isdirectory(session_dir) == 0 then
    vim.fn.mkdir(session_dir, "p")
  end
end

local function normalize_session_name(name)
  local normalized = (name or "last"):gsub("%.vim$", "")
  normalized = normalized:gsub("%s+", "_")
  normalized = normalized:gsub("[^%w%._%-]", "")
  if normalized == "" then
    normalized = "last"
  end
  return normalized
end

local function session_path(name)
  ensure_session_dir()
  local normalized = normalize_session_name(name)
  return session_dir .. "/" .. normalized .. ".vim"
end

local function session_save(name, opts)
  opts = opts or {}
  local target = session_path(name)
  local ok, err = pcall(vim.cmd, "mksession! " .. vim.fn.fnameescape(target))
  if not ok then
    if not opts.silent then
      vim.notify("Session save failed: " .. err, vim.log.levels.ERROR)
    end
    return
  end
  if not opts.silent then
    vim.notify("Session saved to " .. target, vim.log.levels.INFO)
  end
  return target
end

local function session_load(name, opts)
  opts = opts or {}
  local target = session_path(name)
  if vim.fn.filereadable(target) == 0 then
    if not opts.silent then
      vim.notify("Session not found: " .. target, vim.log.levels.WARN)
    end
    return
  end
  local ok, err = pcall(vim.cmd, "source " .. vim.fn.fnameescape(target))
  if not ok then
    if not opts.silent then
      vim.notify("Session load failed: " .. err, vim.log.levels.ERROR)
    end
    return
  end
  if not opts.silent then
    vim.notify("Session loaded from " .. target, vim.log.levels.INFO)
  end
end

local function session_list()
  ensure_session_dir()
  local files = vim.fn.readdir(session_dir, function(file)
    return file:sub(-4) == ".vim"
  end)
  table.sort(files)
  return files
end

function _G.Session_save_prompt()
  local name = vim.fn.input("Save session name (last): ", "", "file")
  if name == "" then
    name = "last"
  end
  session_save(name)
end

function _G.Session_load_last()
  session_load("last")
end

function _G.Session_select()
  local files = session_list()
  if vim.tbl_isempty(files) then
    vim.notify("No sessions saved in " .. session_dir, vim.log.levels.INFO)
    return
  end
  vim.ui.select(files, { prompt = "Select session" }, function(choice)
    if choice then
      session_load(choice)
    end
  end)
end

-- Notification helper function
local function notify_toggle(enabled, feature)
  local status = enabled and "enabled" or "disabled"
  require("fidget").notify(feature .. " " .. status, vim.log.levels.INFO, { title = feature })
end

-- Image Rendering Toggle Functionality
Image_rendering_enabled = false -- Assume images are disabled by default -- Make global
function _G.Toggle_image_rendering() -- Make global
  if Image_rendering_enabled then
    require("image").disable()
  else
    require("image").enable()
  end
  Image_rendering_enabled = not Image_rendering_enabled
  notify_toggle(Image_rendering_enabled, "Image rendering")
end

-- Toggle R language server using standard vim.lsp APIs
function _G.Toggle_r_language_server()
  local clients = vim.lsp.get_clients({ bufnr = 0, name = "r_language_server" })
  local is_running = #clients > 0

  if is_running then
    -- LSP is running for this buffer, stop all R clients for this buffer
    for _, client in ipairs(clients) do
      vim.lsp.stop_client(client.id)
    end
    notify_toggle(false, "R LSP")
  else
    -- LSP is not running for this buffer, start it
    -- We need configuration details to start the client manually
    local bufname = vim.api.nvim_buf_get_name(0)
    local root_dir = vim.fs.root(bufname, "DESCRIPTION") or vim.fs.root(bufname, ".git") or vim.fs.dirname(bufname)

    if root_dir then
      -- Get capabilities from blink.cmp if available
      local capabilities = nil
      local blink_ok, blink = pcall(require, "blink.cmp")
      if blink_ok then
        capabilities = blink.get_lsp_capabilities()
      end

      vim.lsp.start({
        name = "r_language_server",
        cmd = { "R", "--slave", "-e", "languageserver::run()" },
        root_dir = root_dir,
        capabilities = capabilities,
        filetypes = { "r" }, -- Ensure filetype association
      })
      notify_toggle(true, "R LSP")
    else
      require("fidget").notify(
        "Could not determine project root for R LSP.",
        vim.log.levels.WARN,
        { title = "R LSP" }
      )
    end
  end
end

-- Additional toggle functions with notifications
function _G.Toggle_spell()
  vim.opt.spell = not vim.opt.spell:get()
  notify_toggle(vim.opt.spell:get(), "Spell checking")
end

function _G.Toggle_wrap()
  vim.opt.wrap = not vim.opt.wrap:get()
  notify_toggle(vim.opt.wrap:get(), "Word wrap")
end
