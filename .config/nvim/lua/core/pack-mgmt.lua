---| Plugin Management Functions -----------------------------
-- Module for vim.pack operations: updates, status, diagnostics, cleanup.
-- Exposed via require("core.pack-mgmt") and also via _G stubs for user commands.

local M = {}

--===========================================================================
--| Update Scheduling
--===========================================================================

function M.save_last_check_date()
	local state_file = vim.fn.stdpath("state") .. "/plugins_last_check"
	local date = os.date("%Y-%m-%d")
	vim.fn.writefile({ date }, state_file)
end

function M.get_last_check_date()
	local state_file = vim.fn.stdpath("state") .. "/plugins_last_check"
	if vim.fn.filereadable(state_file) == 0 then
		return nil
	end
	return vim.trim(vim.fn.readfile(state_file)[1])
end

function M.should_check_for_updates()
	local last_check = M.get_last_check_date()
	if not last_check then
		return true
	end
	local last_seconds = os.time({
		year = tonumber(last_check:sub(1, 4)),
		month = tonumber(last_check:sub(6, 7)),
		day = tonumber(last_check:sub(9, 10)),
	})
	local current_seconds = os.time()
	local days_passed = (current_seconds - last_seconds) / 86400
	return days_passed >= 7
end

--===========================================================================
--| Version Helpers
--===========================================================================

-- Get local tag for a plugin (returns nil if no tag)
local function get_local_tag(plugin_path)
	if not plugin_path or vim.fn.isdirectory(plugin_path) == 0 then
		return nil
	end
	local result = vim.system(
		{ "git", "-C", plugin_path, "describe", "--tags", "--abbrev=0", "--exact-match" },
		{ text = true }
	):wait()
	if result.code == 0 and result.stdout then
		local tag = vim.trim(result.stdout)
		return tag:gsub("%^%{%}%$", "")
	end
	return nil
end

-- Parse semver version string (e.g., "v1.2.3" -> {1, 2, 3})
local function parse_semver(version_str)
	if not version_str or version_str == "" then
		return nil
	end
	version_str = version_str:gsub("^v", "")
	local major, minor, patch = version_str:match("^(%d+)%.?(%d*)%.?(%d*)")
	if major then
		return {
			major = tonumber(major) or 0,
			minor = tonumber(minor) or 0,
			patch = tonumber(patch) or 0,
		}
	end
	return nil
end

-- Determine update type between two versions
local function get_update_type(local_ver, remote_ver)
	if not local_ver or not remote_ver then
		return "uncategorized"
	end
	if local_ver:match("^v?%d+%.?%d*%.?%d*") and remote_ver:match("^v?%d+%.?%d*%.?%d*") then
		local local_parsed = parse_semver(local_ver)
		local remote_parsed = parse_semver(remote_ver)
		if local_parsed and remote_parsed then
			if remote_parsed.major > local_parsed.major then
				return "major"
			elseif remote_parsed.minor > local_parsed.minor then
				return "minor"
			elseif remote_parsed.patch > local_parsed.patch then
				return "patch"
			end
		end
	end
	return "uncategorized"
end

-- Format version for display
local function format_version(version, is_tag)
	if is_tag and version then
		return version:gsub("^v", "")
	else
		return version and version:sub(1, 7) or "unknown"
	end
end

--===========================================================================
--| Update Checking
--===========================================================================

function M.check_updates()
	vim.notify("Checking for plugin updates...", vim.log.levels.INFO)

	local plugins = vim.pack.get()
	local updatable = {}

	for _, plugin in ipairs(plugins) do
		if plugin.path and plugin.spec and plugin.spec.src then
			local local_tag = get_local_tag(plugin.path)
			local local_version = local_tag or plugin.rev:sub(1, 8)
			local repo_url = plugin.spec.src
			local name = plugin.spec.name or vim.fn.fnamemodify(plugin.path, ":t")

			vim.system({ "git", "ls-remote", "--tags", "--heads", repo_url }, { text = true }, function(result)
				if result.code == 0 and result.stdout then
					local latest_ref = nil
					local latest_tag = nil

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

					if latest_tag then
						latest_tag = latest_tag:gsub("%^%{%}%$", "")
					end

					if latest_ref then
						local has_update = false
						if local_tag then
							has_update = (not latest_tag) or (local_tag ~= latest_tag)
						else
							has_update = (plugin.rev ~= latest_ref)
						end

						if has_update then
							local local_display_ver = local_tag or local_version:sub(1, 7)
							local remote_display_ver = latest_tag or latest_ref:sub(1, 7)
							local update_type = get_update_type(local_display_ver, remote_display_ver)

							table.insert(updatable, {
								name = name,
								local_version = local_display_ver,
								remote_version = remote_display_ver,
								local_is_tag = local_tag ~= nil,
								remote_is_tag = latest_tag ~= nil,
								update_type = update_type,
							})
						end
					end
				end
			end)
		end
	end

	vim.defer_fn(function()
		if #updatable > 0 then
			local grouped = { major = {}, minor = {}, patch = {}, uncategorized = {} }
			for _, p in ipairs(updatable) do
				table.insert(grouped[p.update_type] or grouped.uncategorized, p)
			end
			for _, group in pairs(grouped) do
				table.sort(group, function(a, b)
					return a.name < b.name
				end)
			end

			local msg = string.format("%d plugin(s) have updates available:\n", #updatable)
			local order = { "major", "minor", "patch", "uncategorized" }
			local labels = { major = "Major", minor = "Minor", patch = "Patch", uncategorized = "Version changes" }
			local first = true
			for _, key in ipairs(order) do
				local group = grouped[key]
				if #group > 0 then
					if not first then
						msg = msg .. "\n"
					end
					first = false
					msg = msg .. "\n" .. labels[key] .. " updates:"
					for _, p in ipairs(group) do
						local lf = format_version(p.local_version, p.local_is_tag)
						local rf = format_version(p.remote_version, p.remote_is_tag)
						msg = msg .. string.format("\n  • %-30s %s → %s", p.name, lf, rf)
					end
				end
			end
			vim.notify(msg, vim.log.levels.INFO)
		else
			vim.notify("All plugins are up to date.", vim.log.levels.INFO)
		end
	end, 3000)

	return updatable
end

--===========================================================================
--| Diagnostics
--===========================================================================

local function parse_urls_from_error(err)
	local urls = {}
	for url in tostring(err):gmatch("https?://[^%s']+") do
		urls[url:gsub("/$", "")] = true
	end
	return urls
end

function M.diagnose_fetch_failures(failed_urls)
	local plugins = vim.pack.get()
	local failures = {}
	local filter_urls = failed_urls or {}
	local use_filter = next(filter_urls) ~= nil

	for _, plugin in ipairs(plugins) do
		if plugin.spec and plugin.spec.src then
			local src = plugin.spec.src:gsub("/$", "")
			if (not use_filter) or filter_urls[src] then
				local ok_wait, result = pcall(function()
					return vim.system({ "git", "ls-remote", "--exit-code", "--heads", "--tags", src }, { text = true }):wait(10000)
				end)

				if not ok_wait then
					table.insert(failures, {
						name = plugin.spec.name or vim.fn.fnamemodify(plugin.path, ":t"),
						src = src,
						error = "diagnostic check failed to run",
					})
				elseif result.code ~= 0 then
					local msg = vim.trim(result.stderr or result.stdout or ("git exited with code " .. tostring(result.code)))
					table.insert(failures, {
						name = plugin.spec.name or vim.fn.fnamemodify(plugin.path, ":t"),
						src = src,
						error = msg,
					})
				end
			end
		end
	end

	if #failures == 0 then
		vim.notify("PackDiagnose: all checked plugin remotes are reachable.", vim.log.levels.INFO)
		return failures
	end

	table.sort(failures, function(a, b)
		return a.name < b.name
	end)

	local lines = { string.format("PackDiagnose: %d plugin remote(s) failed:", #failures) }
	for _, failure in ipairs(failures) do
		local short_error = failure.error:gsub("\n+", " ")
		if #short_error > 140 then
			short_error = short_error:sub(1, 140) .. "…"
		end
		table.insert(lines, string.format("  • %s\n    %s\n    %s", failure.name, failure.src, short_error))
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.ERROR)
	return failures
end

--===========================================================================
--| Update Operations
--===========================================================================

function M.update_all(force)
	vim.notify((force and "Force updating" or "Updating") .. " all plugins...", vim.log.levels.INFO)
	M.save_last_check_date()
	local ok, err = pcall(vim.pack.update)
	if ok then
		vim.notify("Plugins updated successfully!", vim.log.levels.INFO)
	else
		local err_msg = tostring(err)
		vim.notify("Plugin update failed: " .. err_msg, vim.log.levels.ERROR)
		local failed_urls = parse_urls_from_error(err_msg)
		vim.schedule(function()
			M.diagnose_fetch_failures(failed_urls)
		end)
	end
end

function M.update_plugin(plugin_path)
	if not plugin_path or vim.fn.isdirectory(plugin_path) == 0 then
		vim.notify("Invalid plugin path: " .. tostring(plugin_path), vim.log.levels.ERROR)
		return
	end
	local plugin_name = vim.fn.fnamemodify(plugin_path, ":t")
	vim.notify("Updating plugin: " .. plugin_name, vim.log.levels.INFO)
	vim.system({ "git", "-C", plugin_path, "pull", "--ff-only" }, { text = true }, function(result)
		vim.schedule(function()
			if result.code == 0 then
				vim.notify("Plugin " .. plugin_name .. " updated successfully!", vim.log.levels.INFO)
			else
				vim.notify("Failed to update " .. plugin_name .. ": " .. (result.stderr or "Unknown error"), vim.log.levels.ERROR)
			end
		end)
	end)
end

function M.update_picker()
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
	vim.ui.select(plugin_list, {
		prompt = "Select plugin to update",
		format_item = function(item)
			return item.text
		end,
	}, function(selected)
		if selected then
			M.update_plugin(selected.plugin.path)
		end
	end)
end

function M.clean()
	vim.notify("Checking for unused plugins...", vim.log.levels.INFO)
	local active_plugins = _G.Pack_declared_plugins or {}
	if vim.tbl_isempty(active_plugins) then
		vim.notify("No declared plugin list found; refusing to clean.", vim.log.levels.ERROR)
		return
	end

	-- Remove orphaned directories
	local pack_dir = vim.fn.stdpath("data") .. "/site/pack/core"
	local cleaned = 0
	for _, pack_subdir in ipairs({ "start", "opt" }) do
		local dir = pack_dir .. "/" .. pack_subdir
		if vim.fn.isdirectory(dir) == 1 then
			for _, plugin_dir in ipairs(vim.fn.readdir(dir)) do
				if not active_plugins[plugin_dir] then
					vim.fn.delete(dir .. "/" .. plugin_dir, "rf")
					cleaned = cleaned + 1
					vim.notify("Removed: " .. plugin_dir, vim.log.levels.INFO)
				end
			end
		end
	end

	-- Remove orphaned entries from the lockfile
	local lockfile = vim.fn.stdpath("config") .. "/nvim-pack-lock.json"
	if vim.fn.filereadable(lockfile) == 1 then
		local ok, data = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(lockfile), "\n"))
		if ok and data and data.plugins then
			local lock_cleaned = 0
			for name, _ in pairs(data.plugins) do
				if not active_plugins[name] then
					data.plugins[name] = nil
					lock_cleaned = lock_cleaned + 1
				end
			end
			if lock_cleaned > 0 then
				vim.fn.writefile(
					vim.split(vim.fn.json_encode(data), "\n"),
					lockfile
				)
				cleaned = cleaned + lock_cleaned
			end
		end
	end

	if cleaned == 0 then
		vim.notify("No unused plugins found.", vim.log.levels.INFO)
	else
		vim.notify("Cleaned " .. cleaned .. " unused plugin(s).", vim.log.levels.INFO)
	end
end

function M.sync()
	vim.notify("Syncing plugins (update + clean)...", vim.log.levels.INFO)
	M.update_all(false)
	vim.defer_fn(M.clean, 1000)
end

function M.status()
	local plugins = vim.pack.get()
	local status_list = {}
	for _, plugin in ipairs(plugins) do
		local active_status = plugin.active and "active" or "lazy"
		table.insert(status_list, {
			text = string.format("%-30s | %-6s | %s", plugin.spec.name, active_status, plugin.rev:sub(1, 8)),
			plugin = plugin,
		})
	end
	table.sort(status_list, function(a, b)
		return a.plugin.spec.name < b.plugin.spec.name
	end)
	vim.ui.select(status_list, {
		prompt = "Plugin Status",
		format_item = function(item)
			return item.text
		end,
	}, function(selected)
		if selected then
			local p = selected.plugin
			vim.notify(
				string.format("Plugin: %s\nStatus: %s\nPath: %s\nRevision: %s",
					p.spec.name, p.active and "active" or "lazy", p.path, p.rev),
				vim.log.levels.INFO
			)
		end
	end)
end

--===========================================================================
--| _G Stubs (backward compat for user command callbacks referencing _G.Pack_*)
--===========================================================================
_G.Save_last_check_date = M.save_last_check_date
_G.Get_last_check_date = M.get_last_check_date
_G.Should_check_for_updates = M.should_check_for_updates
_G.Pack_check_updates = M.check_updates
_G.Pack_diagnose_fetch_failures = M.diagnose_fetch_failures
_G.Pack_update_all = M.update_all
_G.Pack_update_plugin = M.update_plugin
_G.Pack_update_picker = M.update_picker
_G.Pack_clean = M.clean
_G.Pack_sync = M.sync
_G.Pack_status = M.status

return M
