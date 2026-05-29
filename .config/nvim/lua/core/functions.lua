---| Helper Functions --------------------------------------------
-- Module exposing toggle functions and buffer utilities.
-- Used by keymaps.lua and anywhere else needing these helpers.

local M = {}

-- Notification helper
local function notify_toggle(enabled, feature)
	local status = enabled and "enabled" or "disabled"
	vim.notify(feature .. " " .. status, vim.log.levels.INFO)
end

-- Image Rendering Toggle
M.image_rendering_enabled = false -- default: disabled

function M.toggle_image_rendering()
	if M.image_rendering_enabled then
		require("image").disable()
	else
		require("image").enable()
	end
	M.image_rendering_enabled = not M.image_rendering_enabled
	notify_toggle(M.image_rendering_enabled, "Image rendering")
end

-- Toggle R language server (uses static config from plugins/lsp.lua)
function M.toggle_r_language_server()
	local clients = vim.lsp.get_clients({ name = "r_language_server" })
	if #clients > 0 then
		for _, client in ipairs(clients) do
			client:stop()
		end
		notify_toggle(false, "R LSP")
	else
		vim.lsp.enable("r_language_server")
		notify_toggle(true, "R LSP")
	end
end

-- Toggle spell checking
function M.toggle_spell()
	vim.opt.spell = not vim.opt.spell:get()
	notify_toggle(vim.opt.spell:get(), "Spell checking")
end

-- Toggle word wrap
function M.toggle_wrap()
	vim.opt.wrap = not vim.opt.wrap:get()
	notify_toggle(vim.opt.wrap:get(), "Word wrap")
end

-- Close all buffers except the current one
function M.close_other_buffers()
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

--===========================================================================
--| _G Stubs (backward compat for keymaps using _G.Toggle_*)
--===========================================================================
_G.Toggle_image_rendering = M.toggle_image_rendering
_G.Toggle_r_language_server = M.toggle_r_language_server
_G.Toggle_spell = M.toggle_spell
_G.Toggle_wrap = M.toggle_wrap
_G.Close_other_buffers = M.close_other_buffers

return M
