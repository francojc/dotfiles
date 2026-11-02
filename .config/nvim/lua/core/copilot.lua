---| copilot.vim Configuration ---------------------------------
-- Default inline completion (GitHub Copilot, cloud).
-- llama.vim stays installed but starts disabled (see core/llama.lua).
--
-- Two phases:
--   M.pre_load()  -> before vim.pack.add (sets g: vars the plugin reads at load)
--   M.keymaps()   -> after blink.cmp setup

local M = {}

function M.pre_load()
	-- Tab is not an accept key; <C-g> is. Keep plugin's Tab map off.
	vim.g.copilot_no_tab_map = true
	vim.g.copilot_filetypes = {
		gitcommit = false,
	}
end

-- Run `plug` when a Copilot suggestion is showing, otherwise `fallback`.
-- Keeps <C-d> (dedent) and <C-h> (backspace) working when no suggestion.
local function when_suggestion(plug, fallback)
	return function()
		if vim.fn["copilot#GetDisplayedSuggestion"]().text ~= "" then
			return vim.keycode(plug)
		end
		return vim.keycode(fallback)
	end
end

function M.keymaps()
	-- Accept full (replaces Tab, matching llama.vim's <C-g> config)
	vim.keymap.set("i", "<C-g>", function()
		return vim.fn["copilot#Accept"](vim.keycode("<C-g>"))
	end, { expr = true, replace_keycodes = false, silent = true, desc = "Copilot: accept full" })

	-- Accept line, word, next, previous (llama.vim style)
	vim.keymap.set("i", "<C-f>", "<Plug>(copilot-accept-line)", { desc = "Copilot: accept line (llama <C-f>)" })
	vim.keymap.set(
		"i",
		"<C-d>",
		when_suggestion("<Plug>(copilot-accept-word)", "<C-d>"),
		{ expr = true, replace_keycodes = false, silent = true, desc = "Copilot: accept word (llama <C-d>)" }
	)
	vim.keymap.set(
		"i",
		"<C-l>",
		when_suggestion("<Plug>(copilot-next)", "<C-l>"),
		{ expr = true, replace_keycodes = false, silent = true, desc = "Copilot: next suggestion (llama <C-l>)" }
	)
	vim.keymap.set(
		"i",
		"<C-h>",
		when_suggestion("<Plug>(copilot-previous)", "<BS>"),
		{ expr = true, replace_keycodes = false, silent = true, desc = "Copilot: previous suggestion (llama <C-h>)" }
	)
end

return M
