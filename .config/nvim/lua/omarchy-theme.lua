---| Omarchy theme bridge ----------------------------------------
-- Follows the Omarchy theme. Omarchy records the active theme in
-- ~/.local/state/omarchy/current/theme.name and rewrites theme.generation on
-- every theme switch; this module reads the name at startup and re-applies the
-- matching colorscheme when the directory changes (hot reload).
--
-- The mapping below mirrors each Omarchy theme's neovim.lua (under
-- /usr/share/omarchy/themes/<name>/). Themes without one use M.default.
local M = {}

M.default = "gruvbox"

-- Overridable for testing: OMARCHY_THEME_STATE=/some/dir nvim
M.state_dir = vim.env.OMARCHY_THEME_STATE or (vim.env.HOME .. "/.local/state/omarchy/current")

-- Omarchy theme name -> colorscheme (cs), plugin repo (src), and vim.pack
-- name when the repo basename differs from the plugin name (name).
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

-- Raw theme name from Omarchy's state, or nil when Omarchy has not set one.
function M.theme_name()
	local f = io.open(M.state_dir .. "/theme.name", "r")
	if not f then
		return nil
	end
	local name = f:read("*l")
	f:close()
	return name and vim.trim(name) or nil
end

-- Colorscheme for the active Omarchy theme.
function M.colorscheme()
	local entry = M.themes[M.theme_name() or ""]
	return entry and entry.cs or M.default
end

-- Every colorscheme this bridge can select, as theme-registry entries:
-- { cs = colorscheme, spec = { src = ..., name = ... } }.
function M.registry_entries()
	local out = {}
	for _, entry in pairs(M.themes) do
		table.insert(out, { cs = entry.cs, spec = { src = entry.src, name = entry.name } })
	end
	return out
end

-- Load the plugin for `cs` (if it is an opt plugin) and select the colorscheme.
function M.activate(cs)
	for _, entry in pairs(M.themes) do
		if entry.cs == cs then
			for _, p in ipairs(vim.pack.get()) do
				if p.spec.src == entry.src then
					pcall(vim.cmd.packadd, p.spec.name)
					break
				end
			end
			break
		end
	end
	local ok, err = pcall(vim.cmd.colorscheme, cs)
	if not ok then
		vim.notify("omarchy-theme: could not load '" .. cs .. "': " .. tostring(err), vim.log.levels.WARN)
	end
end

-- Re-apply the colorscheme whenever Omarchy changes the active theme.
-- Returns the fs_event handle (nil when the state directory does not exist).
function M.watch()
	local handle = vim.uv.new_fs_event()
	if not handle then
		return nil
	end
	local last = M.theme_name()
	local ok = handle:start(M.state_dir, {}, function(err, filename)
		if err or (filename ~= "theme.name" and filename ~= "theme.generation") then
			return
		end
		vim.schedule(function()
			local name = M.theme_name()
			if name and name ~= last then
				last = name
				M.activate(M.colorscheme())
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
