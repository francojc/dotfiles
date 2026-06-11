--| critic-highlights.lua -------------------------------------
-- Define CriticMarkup highlight groups with default link targets.
-- Users can override by setting `vim.g.critic_highlights = { ... }`
-- before Neovim loads, or by linking groups in their colorscheme.
--
-- Default links:
--   critic.insert    → DiffAdd
--   critic.delete    → DiffDelete
--   critic.subst     → DiffChange
--   critic.highlight → DiffText
--   critic.comment   → DiagnosticInfo

local M = {}

local defaults = {
	["critic.insert"]    = "DiffAdd",
	["critic.delete"]    = "DiffDelete",
	["critic.subst"]     = "DiffChange",
	["critic.highlight"] = "DiffText",
	["critic.comment"]   = "DiagnosticInfo",
}

function M.setup(user_overrides)
	local groups = vim.tbl_deep_extend("force", defaults, user_overrides or {})
	for src, dst in pairs(groups) do
		-- Only link if both groups exist (depends on colorscheme)
		local ok_src = pcall(vim.api.nvim_get_hl, 0, { name = src })
		local ok_dst = pcall(vim.api.nvim_get_hl, 0, { name = dst })
		if not ok_src or not ok_dst then
			-- Define source with a fallback color
			local default_colors = {
				["critic.insert"]    = { fg = "#a6e3a1", bg = "#1e3a1e" }, -- green
				["critic.delete"]    = { fg = "#f38ba8", bg = "#3a1e1e" }, -- red
				["critic.subst"]     = { fg = "#fab387", bg = "#3a2e1e" }, -- orange
				["critic.highlight"] = { fg = "#f9e2af", bg = "#3a3a1e" }, -- yellow
				["critic.comment"]   = { fg = "#89b4fa", bg = "#1e2a3a" }, -- blue
			}
			vim.api.nvim_set_hl(0, src, default_colors[src] or { fg = "#cdd6f4" })
		end
		-- Always link if dest exists; otherwise leave the explicit definition
		if ok_dst then
			vim.api.nvim_set_hl(0, src, { link = dst, default = true })
		end
	end
end

return M
