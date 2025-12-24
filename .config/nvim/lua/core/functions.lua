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

-- Search count helper for statusline with caching
-- Cache structure: { [bufnr] = { count = string, pattern = string, hlsearch = boolean } }
local search_count_cache = {}

-- Debouncing variables
local last_update_time = 0
local last_cursor_pos = nil
local DEBOUNCE_DELAY = 50 -- ms between updates

-- Update search count asynchronously for current buffer
local function update_search_count_async()
	local bufnr = vim.api.nvim_get_current_buf()
	local current_time = vim.loop.hrtime() / 1000000 -- Convert to milliseconds

	-- Check if search highlighting is active
	local hlsearch = vim.o.hlsearch
	if not hlsearch then
		search_count_cache[bufnr] = { count = "", pattern = "", hlsearch = false }
		return
	end

	-- Get current search pattern
	local pattern = vim.fn.getreg("/")
	if pattern == "" then
		search_count_cache[bufnr] = { count = "", pattern = "", hlsearch = false }
		return
	end

	-- Get current cursor position
	local current_cursor = { vim.fn.line('.'), vim.fn.col('.') }
	local cursor_str = string.format("%d,%d", current_cursor[1], current_cursor[2])

	-- Debouncing: only update if enough time has passed or cursor moved significantly
	if current_time - last_update_time < DEBOUNCE_DELAY then
		if last_cursor_pos and cursor_str == last_cursor_pos then
			return -- Skip update for same position within debounce window
		end
	end

	-- Update tracking variables
	last_update_time = current_time
	last_cursor_pos = cursor_str

	-- Get search count with error handling
	local ok, result = pcall(vim.fn.searchcount, {
		maxcount = 9999, -- Set high limit to get most results
		timeout = 100,   -- Quick timeout to avoid blocking
	})

	if ok and result and result.total and result.total > 0 then
		local current = result.current or 0
		local total = result.total or 0
		local new_count = string.format(" %d/%d ", current, total)

		-- Only update if count actually changed (to avoid unnecessary redraws)
		local cached = search_count_cache[bufnr]
		if not cached or cached.count ~= new_count or cached.pattern ~= pattern or cached.hlsearch ~= hlsearch then
			search_count_cache[bufnr] = {
				count = new_count,
				pattern = pattern,
				hlsearch = hlsearch,
			}
			-- Trigger statusline redraw only when count changes
			vim.schedule(function()
				vim.cmd("redrawstatus")
			end)
		end
	else
		-- No matches or error - clear display
		local cached = search_count_cache[bufnr]
		if not cached or cached.count ~= "" then
			search_count_cache[bufnr] = {
				count = "",
				pattern = pattern,
				hlsearch = hlsearch,
			}
			vim.schedule(function()
				vim.cmd("redrawstatus")
			end)
		end
	end
end

-- Get search count from cache (non-blocking)
function _G.Get_search_count()
	local bufnr = vim.api.nvim_get_current_buf()

	-- Always check hlsearch state and search pattern first
	if not vim.o.hlsearch then
		-- Clear cache when hlsearch is disabled
		search_count_cache[bufnr] = nil
		return ""
	end

	-- Check if search pattern exists
	local pattern = vim.fn.getreg("/")
	if pattern == "" then
		search_count_cache[bufnr] = nil
		return ""
	end

	local cached = search_count_cache[bufnr]
	if cached and cached.hlsearch and cached.pattern == pattern then
		return cached.count or ""
	end

	-- Cache miss - trigger async update and return empty for now
	update_search_count_async()
	return ""
end

-- Expose update function globally for autocommands
function _G.Update_search_count_cache()
	update_search_count_async()
end

---============================================================
---| PLUGIN MANAGEMENT FUNCTIONS
---============================================================

-- Update state tracking
function _G.Save_last_check_date()
	local state_file = vim.fn.stdpath("state") .. "/plugins_last_check"
	local date = os.date("%Y-%m-%d")
	vim.fn.writefile({ date }, state_file)
end

function _G.Get_last_check_date()
	local state_file = vim.fn.stdpath("state") .. "/plugins_last_check"
	if vim.fn.filereadable(state_file) == 0 then
		return nil
	end
	return vim.trim(vim.fn.readfile(state_file)[1])
end

function _G.Should_check_for_updates()
	local last_check = _G.Get_last_check_date()
	if not last_check then
		return true
	end
	local last_seconds = os.time({ year = tonumber(last_check:sub(1, 4)), month = tonumber(last_check:sub(6, 7)), day = tonumber(last_check:sub(9, 10)) })
	local current_seconds = os.time()
	local days_passed = (current_seconds - last_seconds) / 86400
	return days_passed >= 7
end

-- Check for available updates
function _G.Pack_check_updates()
	vim.notify("Checking for plugin updates...", vim.log.levels.INFO)

	local plugins = vim.pack.get()
	local updatable = {}

	for _, plugin in ipairs(plugins) do
		if plugin.path and plugin.spec and plugin.spec.src then
			-- Get latest remote rev asynchronously
			local repo_url = plugin.spec.src
			local name = plugin.spec.name or vim.fn.fnamemodify(plugin.path, ":t")

			-- Try to get latest tag or commit from remote
			vim.system(
				{ "git", "ls-remote", "--tags", "--heads", repo_url },
				{ text = true },
				function(result)
					if result.code == 0 and result.stdout then
						local latest_ref = nil
						local latest_tag = nil

						-- Find latest tag (looks like refs/tags/vX.X.X)
						for line in result.stdout:gmatch("[^\r\n]+") do
							if line:match("^%-?%w+%s+refs/tags/") then
								local ref_name = line:match("refs/tags/(.+)")
								if ref_name and not ref_name:match("^%^{}$") then
									if not latest_tag or ref_name > latest_tag then
										latest_tag = ref_name
										latest_ref = line:match("^%w+")
									end
								end
							end
						end

						if latest_ref and plugin.rev ~= latest_ref then
							table.insert(updatable, {
								name = name,
								current = plugin.rev,
								latest = latest_ref,
								tag = latest_tag,
								path = plugin.path,
							})
						end
					end
				end
			)
		end
	end

	-- Wait a bit for async calls to complete, then return results
	vim.defer_fn(function()
		if #updatable > 0 then
			local msg = string.format("%d plugin(s) have updates available:", #updatable)
			for _, p in ipairs(updatable) do
				msg = msg .. string.format("\n  - %s (%s → %s)", p.name, p.current:sub(1, 8), p.tag or p.latest:sub(1, 8))
			end
			vim.notify(msg, vim.log.levels.INFO)
		else
			vim.notify("All plugins are up to date.", vim.log.levels.INFO)
		end
	end, 2000)

	return updatable
end

-- Update all plugins
function _G.Pack_update_all(force)
	if force then
		vim.notify("Force updating all plugins...", vim.log.levels.INFO)
	else
		vim.notify("Updating all plugins...", vim.log.levels.INFO)
	end

	_G.Save_last_check_date()

	local ok, err = pcall(vim.pack.update)

	if ok then
		vim.notify("Plugins updated successfully!", vim.log.levels.INFO)
	else
		vim.notify("Plugin update failed: " .. tostring(err), vim.log.levels.ERROR)
	end
end

-- Update specific plugin
function _G.Pack_update_plugin(plugin_path)
	if not plugin_path or not vim.fn.isdirectory(plugin_path) then
		vim.notify("Invalid plugin path: " .. tostring(plugin_path), vim.log.levels.ERROR)
		return
	end

	local plugin_name = vim.fn.fnamemodify(plugin_path, ":t")
	vim.notify("Updating plugin: " .. plugin_name, vim.log.levels.INFO)

	vim.system({ "git", "-C", plugin_path, "pull", "--ff-only" }, { text = true }, function(result)
		if result.code == 0 then
			vim.schedule(function()
				vim.notify("Plugin " .. plugin_name .. " updated successfully!", vim.log.levels.INFO)
			end)
		else
			vim.schedule(function()
				vim.notify(
					"Failed to update " .. plugin_name .. ": " .. (result.stderr or "Unknown error"),
					vim.log.levels.ERROR
				)
			end)
		end
	end)
end

-- Update specific plugin via picker
function _G.Pack_update_picker()
	local plugins = vim.pack.get()
	local plugin_list = {}

	for _, plugin in ipairs(plugins) do
		table.insert(plugin_list, {
			text = string.format("%-30s | %s", plugin.spec.name, plugin.rev:sub(1, 8)),
			plugin = plugin,
		})
	end

	table.sort(plugin_list, function(a, b)
		return a.plugin.spec.name < b.plugin.spec.name
	end)

	Snacks.picker.pick({
		source = "plugins",
		items = plugin_list,
		format = function(item, ctx)
			local highlight = item.plugin.active and "SnacksPickerListTitle" or "Comment"
			return { { item.text, highlight }, { item.plugin.path, "Comment" } }
		end,
	}, {}, function(selected)
		if selected then
			_G.Pack_update_plugin(selected.plugin.path)
		end
	end)
end

-- Clean unused plugins
function _G.Pack_clean()
	vim.notify("Checking for unused plugins...", vim.log.levels.INFO)

	local plugins = vim.pack.get()
	local active_plugins = {}
	for _, plugin in ipairs(plugins) do
		active_plugins[vim.fn.fnamemodify(plugin.path, ":t")] = true
	end

	local pack_dir = vim.fn.stdpath("data") .. "/site/pack/core"
	local cleaned = 0

	for _, pack_subdir in ipairs({ "start", "opt" }) do
		local dir = pack_dir .. "/" .. pack_subdir
		if vim.fn.isdirectory(dir) == 1 then
			local plugin_dirs = vim.fn.readdir(dir)
			for _, plugin_dir in ipairs(plugin_dirs) do
				if not active_plugins[plugin_dir] then
					local full_path = dir .. "/" .. plugin_dir
					vim.fn.delete(full_path, "rf")
					cleaned = cleaned + 1
					vim.notify("Removed: " .. plugin_dir, vim.log.levels.INFO)
				end
			end
		end
	end

	if cleaned == 0 then
		vim.notify("No unused plugins found.", vim.log.levels.INFO)
	else
		vim.notify("Cleaned " .. cleaned .. " unused plugin(s).", vim.log.levels.INFO)
	end
end

-- Sync (install + update + clean)
function _G.Pack_sync()
	vim.notify("Syncing plugins (install + update + clean)...", vim.log.levels.INFO)
	_G.Pack_update_all(false)
	vim.defer_fn(function()
		_G.Pack_clean()
	end, 1000)
end

-- Show plugin status
function _G.Pack_status()
	local plugins = vim.pack.get()
	local status_list = {}

	for _, plugin in ipairs(plugins) do
		local active_status = plugin.active and "active" or "lazy"
		local status = string.format(
			"%-30s | %-6s | %s",
			plugin.spec.name,
			active_status,
			plugin.rev:sub(1, 8)
		)
		table.insert(status_list, {
			text = status,
			plugin = plugin,
		})
	end

	table.sort(status_list, function(a, b)
		return a.plugin.spec.name < b.plugin.spec.name
	end)

	Snacks.picker.pick({
		source = "plugin_status",
		items = status_list,
		format = function(item, ctx)
			local active_status = item.plugin.active and "active" or "lazy"
			local highlight = item.plugin.active and "SnacksPickerListTitle" or "Comment"
			return {
				{ item.plugin.spec.name, highlight },
				{ " | " },
				{ active_status, highlight },
				{ " | " },
				{ item.plugin.rev:sub(1, 8), "Comment" },
			}
		end,
	})
end
