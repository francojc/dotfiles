---| Functions --------------------------------------------

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
	vim.notify(feature .. " " .. status, vim.log.levels.INFO)
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
			vim.notify("Could not determine project root for R LSP.", vim.log.levels.WARN)
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

-- Buffer management function
function _G.Close_other_buffers()
	local current_buf = vim.fn.bufnr("%")
	local buffers = vim.api.nvim_list_bufs()
	local closed_count = 0

	for _, buf in ipairs(buffers) do
		if buf ~= current_buf and vim.api.nvim_buf_is_valid(buf) then
			local ok = pcall(vim.api.nvim_buf_delete, buf, { force = true })
			if ok then
				closed_count = closed_count + 1
			end
		end
	end

	vim.notify(closed_count .. " buffer(s) closed", vim.log.levels.INFO)
end

-- Workaround for vim.pack.update() sha_target error in Neovim 0.12 pre-release
-- The update function works but fails when displaying results due to a bug
-- This wrapper suppresses the error and shows a simple success message
-- function _G.Pack_update()
-- 	vim.notify("Updating plugins...", vim.log.levels.INFO)
--
-- 	local ok, err = pcall(vim.pack.update)
--
-- 	if not ok then
-- 		if string.match(tostring(err), "sha_target") then
-- 			vim.notify("Plugins updated successfully (display error suppressed)", vim.log.levels.INFO)
-- 			vim.notify("Check :messages or ~/.local/state/nvim/nvim-pack.log for details", vim.log.levels.INFO)
-- 		else
-- 			vim.notify("Plugin update failed: " .. tostring(err), vim.log.levels.ERROR)
-- 		end
-- 	else
-- 		vim.notify("Plugins updated successfully", vim.log.levels.INFO)
-- 	end
-- end

-- Git branch helper for statusline with caching
-- Cache structure: { [bufnr] = { branch = string, git_dir = string } }
local git_branch_cache = {}

-- Update git branch asynchronously for current buffer
local function update_git_branch_async()
	local bufnr = vim.api.nvim_get_current_buf()

	-- Check if we're in a git repository by looking for .git directory
	local git_dir = vim.fn.finddir(".git", vim.fn.expand("%:p:h") .. ";")
	if git_dir == "" then
		git_branch_cache[bufnr] = { branch = "", git_dir = "" }
		return
	end

	-- Store git_dir to detect directory changes
	if not git_branch_cache[bufnr] then
		git_branch_cache[bufnr] = { branch = "", git_dir = git_dir }
	else
		git_branch_cache[bufnr].git_dir = git_dir
	end

	-- Get current branch asynchronously using vim.system (Neovim 0.12+)
	vim.system({ "git", "branch", "--show-current" }, {
		text = true,
		cwd = vim.fn.expand("%:p:h"),
	}, function(result)
		-- Callback runs asynchronously
		if result.code == 0 and result.stdout then
			local branch = vim.trim(result.stdout)
			if branch ~= "" then
				git_branch_cache[bufnr] = {
					branch = " " .. branch .. " ",
					git_dir = git_dir,
				}
			else
				git_branch_cache[bufnr] = { branch = "", git_dir = git_dir }
			end
			-- Trigger statusline redraw
			vim.schedule(function()
				vim.cmd("redrawstatus")
			end)
		end
	end)
end

-- Get git branch from cache (non-blocking)
function _G.Get_git_branch()
	local bufnr = vim.api.nvim_get_current_buf()
	local cached = git_branch_cache[bufnr]

	if cached then
		return cached.branch or ""
	end

	-- Cache miss - trigger async update and return empty for now
	update_git_branch_async()
	return ""
end

-- Expose update function globally for autocommands
function _G.Update_git_branch_cache()
	update_git_branch_async()
end

-- Get full mode name for statusline
function _G.Get_mode_name()
	local mode_map = {
		n = "NORMAL",
		i = "INSERT",
		v = "VISUAL",
		V = "V-LINE",
		["\22"] = "V-BLOCK", -- Ctrl-V
		c = "COMMAND",
		s = "SELECT",
		S = "S-LINE",
		["\19"] = "S-BLOCK", -- Ctrl-S
		R = "REPLACE",
		r = "REPLACE",
		["!"] = "SHELL",
		t = "TERMINAL",
	}
	local current_mode = vim.fn.mode()
	return mode_map[current_mode] or current_mode:upper()
end
