---| Omarchy theme bridge ----------------------------------------
-- Selects this host's colorscheme, in order:
--   1. Omarchy host (state file theme.name exists):
--      a. theme/neovim.lua rendered by Omarchy for the active theme (source of truth)
--      b. M.themes, for themes that ship no rendered neovim.lua
--   2. Any other host (Darwin, NixOS, or no Omarchy theme): the colorscheme Nix
--      declared for this host (home/themes/themes.nix writes lua/theme-config.lua),
--      else gruvbox.
-- Omarchy hosts hot reload when theme.name or theme.generation changes.
local M = {}

-- Static colorscheme for non-Omarchy hosts.
local function nix_colorscheme()
	local ok, cfg = pcall(require, "theme-config")
	if ok and type(cfg) == "table" and type(cfg.colorscheme) == "string" then
		return cfg.colorscheme
	end
end

M.default = nix_colorscheme() or "gruvbox"

-- Overridable for testing: OMARCHY_THEME_STATE=/some/dir nvim
M.state_dir = vim.env.OMARCHY_THEME_STATE or (vim.env.HOME .. "/.local/state/omarchy/current")

-- Omarchy desktop notifier. Overridable: OMARCHY_NOTIFIER=/path nvim
M.notifier = vim.env.OMARCHY_NOTIFIER or "omarchy-notification-send"

-- Fallback for Omarchy themes with no rendered neovim.lua. Omarchy theme name ->
-- colorscheme (cs), plugin repo (src), and vim.pack name when it differs (name).
M.themes = {
	["catppuccin"] = { cs = "catppuccin-mocha", src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	["catppuccin-latte"] = { cs = "catppuccin-latte", src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	["everforest"] = { cs = "everforest", src = "https://github.com/neanias/everforest-nvim" },
	["flexoki-light"] = { cs = "flexoki-light", src = "https://github.com/kepano/flexoki-neovim" },
	["gruvbox"] = { cs = "gruvbox", src = "https://github.com/ellisonleao/gruvbox.nvim" },
	["hackerman"] = { cs = "hackerman", src = "https://github.com/bjarneo/hackerman.nvim" },
	["kanagawa"] = { cs = "kanagawa", src = "https://github.com/rebelot/kanagawa.nvim" },
	["lumon"] = { cs = "lumon", src = "https://github.com/omacom-io/lumon.nvim" },
	["matte-black"] = { cs = "matteblack", src = "https://github.com/tahayvr/matteblack.nvim" },
	["nord"] = { cs = "nordfox", src = "https://github.com/EdenEast/nightfox.nvim" },
	["retro-82"] = { cs = "retro-82", src = "https://github.com/OldJobobo/retro-82.nvim" },
	["rose-pine"] = { cs = "rose-pine-dawn", src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
	["solitude"] = { cs = "ashen", src = "https://github.com/ficcdaf/ashen.nvim" },
	["tokyo-night"] = { cs = "tokyonight-night", src = "https://github.com/folke/tokyonight.nvim" },
}

-- One trimmed line from a state file, or nil when missing or empty.
local function read_line(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local line = f:read("*l")
	f:close()
	line = line and vim.trim(line) or ""
	return line ~= "" and line or nil
end

function M.theme_name()
	return read_line(M.state_dir .. "/theme.name")
end

function M.generation()
	return read_line(M.state_dir .. "/theme.generation")
end

-- True when Omarchy has written a theme name.
function M.is_omarchy()
	return M.theme_name() ~= nil
end

-- Parse Omarchy's rendered neovim.lua, a lazy.nvim-style spec list:
--   { {"owner/repo", name=, branch=, opts=}, {"LazyVim/LazyVim", opts={colorscheme=}} }
-- Returns { cs, spec?, opts? } or nil. The file runs with an empty environment.
local function parse_rendered(path)
	local chunk = loadfile(path)
	if not chunk then
		return nil
	end
	if setfenv then
		setfenv(chunk, {}) -- LuaJIT
	end
	local ok, specs = pcall(chunk)
	if not ok or type(specs) ~= "table" then
		return nil
	end

	local cs, plugin
	for _, s in ipairs(specs) do
		if type(s) == "table" and type(s[1]) == "string" then
			if s[1] == "LazyVim/LazyVim" then
				if type(s.opts) == "table" and type(s.opts.colorscheme) == "string" then
					cs = s.opts.colorscheme
				end
			elseif not plugin then
				plugin = s
			end
		end
	end
	if not cs then
		return nil
	end

	local out = { cs = cs }
	if plugin then
		local src = plugin[1]
		if not src:find("://", 1, true) then
			src = "https://github.com/" .. src
		end
		out.spec = { src = src, name = plugin.name, version = plugin.branch }
		out.opts = type(plugin.opts) == "table" and plugin.opts or nil
	end
	return out
end

-- What this host should run now: { cs, spec?, opts?, source }.
-- source is "omarchy", "map", or "nix". spec is nil when no plugin is needed
-- (the registry in plugins-pack.lua supplies it).
function M.resolve()
	local res
	if M.is_omarchy() then
		res = parse_rendered(M.state_dir .. "/theme/neovim.lua")
		if res then
			res.source = "omarchy"
		else
			local entry = M.themes[M.theme_name()]
			if entry then
				res = { cs = entry.cs, spec = { src = entry.src, name = entry.name }, source = "map" }
			else
				-- Omarchy theme with no Neovim mapping at all.
				res = { cs = M.default, source = "nix", unmapped = true }
			end
		end
	end
	res = res or { cs = M.default, source = "nix" }
	res.theme = M.theme_name() -- Omarchy theme name, for messages
	M.current = res -- read by plugins-pack.lua / plugins-config.lua
	return res
end

-- Colorscheme name only (kept for callers that just need the name).
function M.colorscheme()
	return M.resolve().cs
end

-- Every colorscheme in the fallback map, as theme-registry entries:
-- { cs = colorscheme, spec = { src = ..., name = ... } }.
function M.registry_entries()
	local out = {}
	for _, entry in pairs(M.themes) do
		table.insert(out, { cs = entry.cs, spec = { src = entry.src, name = entry.name } })
	end
	return out
end

local function plugin_name(spec)
	return spec.name or spec.src:match("([^/]+)$")
end

-- Make sure the plugin for `spec` is installed and on the runtimepath. A plugin
-- already declared in plugins-pack.lua is only packadd'ed; an unknown one is
-- installed with vim.pack and recorded for PackClean.
local function ensure_plugin(spec)
	for _, p in ipairs(vim.pack.get()) do
		if p.spec.src == spec.src then
			pcall(vim.cmd.packadd, p.spec.name)
			return
		end
	end
	vim.pack.add({ spec }, { load = true, confirm = false })
	_G.Pack_declared_plugins = _G.Pack_declared_plugins or {}
	_G.Pack_declared_plugins[plugin_name(spec)] = true
end

-- lazy.nvim `opts` are the plugin's setup() table. Applied before the colorscheme.
local function apply_opts(spec, opts)
	local mod = plugin_name(spec):gsub("%.nvim$", "")
	local ok, m = pcall(require, mod)
	if ok and type(m) == "table" and type(m.setup) == "function" then
		local ok_setup, err = pcall(m.setup, opts)
		if not ok_setup then
			vim.notify("omarchy-theme: setup for '" .. mod .. "' failed: " .. tostring(err), vim.log.levels.WARN)
		end
	end
end

-- Tell the user which colorscheme Omarchy asked for, so a (Neo)vim port can be
-- found. `why` is a short reason; `src` is the plugin repo when known.
local function notify_missing(res, why)
	local lines
	if res.unmapped then
		lines = { ("Omarchy theme '%s' has no Neovim colorscheme mapping."):format(res.theme or "?") }
	else
		lines = { ("Omarchy theme '%s' wants colorscheme '%s'."):format(res.theme or "?", res.cs) }
		if res.spec then
			table.insert(lines, "Plugin: " .. res.spec.src)
		end
	end
	if why then
		table.insert(lines, why)
	end
	table.insert(lines, ("Using Nix default '%s'. Look for a (Neo)vim port of '%s'."):format(
		M.default, res.unmapped and (res.theme or "?") or res.cs))
	local body = table.concat(lines, "\n")

	-- Desktop notification via Omarchy's notifier (async, never blocks nvim).
	-- Without it, fall back to an in-editor message.
	if vim.fn.executable(M.notifier) == 1 then
		local headline = lines[1]
		local description = table.concat(vim.list_slice(lines, 2), "\n")
		vim.system({
			M.notifier, "--app-name", "Neovim", "-u", "normal", headline, description,
		}, { detach = true }, function() end)
	else
		vim.notify(body, vim.log.levels.WARN, { title = "omarchy-theme" })
	end
end

-- Install/load the plugin, apply its opts, then select the colorscheme.
-- If the colorscheme cannot be loaded, notify and fall back to the Nix default.
-- `res` is a resolve() result; defaults to resolving now. Returns the record applied.
function M.activate(res)
	res = res or M.resolve()
	if res.unmapped then
		notify_missing(res)
		local applied = { cs = M.default, source = "nix", theme = res.theme, unmapped = true }
		pcall(vim.cmd.colorscheme, M.default)
		M.current = applied
		return applied
	end
	local install_err
	if res.spec then
		local ok, err = pcall(ensure_plugin, res.spec)
		if ok then
			if res.opts then
				apply_opts(res.spec, res.opts)
			end
		else
			install_err = tostring(err)
		end
	end

	if pcall(vim.cmd.colorscheme, res.cs) then
		return res
	end

	-- Could not load the requested scheme. Explain why, then use the Nix default.
	local why
	if install_err then
		why = "Plugin install failed: " .. install_err:gsub("%s+", " ")
	elseif res.source == "nix" then
		why = "No Neovim mapping for this Omarchy theme."
	elseif not res.spec then
		why = "No plugin declared for this colorscheme."
	else
		why = "Plugin is installed but does not provide this colorscheme."
	end
	notify_missing(res, why)

	if res.cs ~= M.default then
		pcall(vim.cmd.colorscheme, M.default)
	end
	local applied = { cs = M.default, source = "nix", theme = res.theme, fallback_for = res.cs }
	M.current = applied
	return applied
end

-- Identifies the current Omarchy theme and its generation.
local function fingerprint()
	return (M.theme_name() or "") .. "|" .. (M.generation() or "")
end

-- Re-apply when Omarchy switches theme. Returns the fs_event handle, or nil on
-- static hosts and when the watch cannot start.
function M.watch()
	if not M.is_omarchy() then
		return nil
	end
	local handle = vim.uv.new_fs_event()
	if not handle then
		return nil
	end
	local last = fingerprint()
	local ok = handle:start(M.state_dir, {}, function(err, filename)
		if err or (filename ~= "theme.name" and filename ~= "theme.generation") then
			return
		end
		vim.schedule(function()
			if not M.is_omarchy() then
				return
			end
			local now = fingerprint()
			if now ~= last then
				last = now
				M.activate(M.resolve())
			end
		end)
	end)
	if ok == nil then
		handle:close()
		return nil
	end
	M.handle = handle -- keep a reference so the watcher is not garbage collected
	return handle
end

return M
