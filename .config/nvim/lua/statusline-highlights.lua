---| Statusline Highlights ---------------------------------
-- Theme-adaptive highlight groups for statusline
-- These groups automatically inherit colors from the active colorscheme

local M = {}

function M.setup()
	-- Helper to get highlight attributes
	local function get_hl(name)
		return vim.api.nvim_get_hl(0, { name = name })
	end

	-- Diagnostics - direct links to semantic groups
	vim.api.nvim_set_hl(0, "StatusLineDiagError", { link = "DiagnosticError" })
	vim.api.nvim_set_hl(0, "StatusLineDiagWarn", { link = "DiagnosticWarn" })
	vim.api.nvim_set_hl(0, "StatusLineDiagInfo", { link = "DiagnosticInfo" })
	vim.api.nvim_set_hl(0, "StatusLineDiagHint", { link = "DiagnosticHint" })

	-- Git branch - link to Directory (typically blue/cyan in most themes)
	vim.api.nvim_set_hl(0, "StatusLineGit", { link = "Directory" })

	-- Modified indicator - link to Visual for visibility
	vim.api.nvim_set_hl(0, "StatusLineModified", { link = "Visual" })

	-- Muted text (filetype, position) - link to Comment
	vim.api.nvim_set_hl(0, "StatusLineMuted", { link = "Comment" })

	-- Dynamic mode indicators with inverted colors for prominence
	local normal = get_hl("Normal")
	local keyword = get_hl("Keyword")
	local string = get_hl("String")
	local special = get_hl("Special")
	local type_hl = get_hl("Type")

	-- Fallback colors if theme doesn't define these groups
	local bg = normal.bg or 0
	local keyword_fg = keyword.fg or 10066329 -- fallback gray
	local string_fg = string.fg or 10857127 -- fallback green
	local special_fg = special.fg or 6450023 -- fallback cyan
	local type_fg = type_hl.fg or 14204888 -- fallback yellow

	-- Mode: Normal (inverted keyword color)
	vim.api.nvim_set_hl(0, "StatusLineModeNormal", {
		fg = bg,
		bg = keyword_fg,
		bold = true,
	})

	-- Mode: Insert (inverted string color)
	vim.api.nvim_set_hl(0, "StatusLineModeInsert", {
		fg = bg,
		bg = string_fg,
		bold = true,
	})

	-- Mode: Visual (inverted special color)
	vim.api.nvim_set_hl(0, "StatusLineModeVisual", {
		fg = bg,
		bg = special_fg,
		bold = true,
	})

	-- Mode: Command (inverted type color)
	vim.api.nvim_set_hl(0, "StatusLineModeCommand", {
		fg = bg,
		bg = type_fg,
		bold = true,
	})

	-- Filename - slightly bold for prominence
	vim.api.nvim_set_hl(0, "StatusLineFilename", {
		fg = normal.fg,
		bg = normal.bg,
		bold = true,
	})
end

return M
