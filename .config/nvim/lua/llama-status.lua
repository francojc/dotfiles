---| llama.vim Statusline Spinner ---------------------------------
-- Shows an animated spinner in the statusline while llama.vim may
-- be processing a FIM request. Heuristic: starts on first CursorMovedI
-- in insert mode, auto-expires after t_max_prompt_ms + t_max_predict_ms,
-- clears immediately on InsertLeavePre.

local M = {}

local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local frame_idx = 0
local spinner_timer = nil
local timeout_timer = nil

local function clear()
	if spinner_timer then
		spinner_timer:stop()
		spinner_timer:close()
		spinner_timer = nil
	end
	if timeout_timer then
		timeout_timer:stop()
		timeout_timer:close()
		timeout_timer = nil
	end
	vim.g.llama_status = ""
	vim.cmd("redrawstatus")
end

local function start()
	if spinner_timer then
		return -- already running, let it finish
	end
	frame_idx = 0
	spinner_timer = vim.uv.new_timer()
	spinner_timer:start(
		0,
		80,
		vim.schedule_wrap(function()
			frame_idx = (frame_idx % #frames) + 1
			vim.g.llama_status = frames[frame_idx]
			vim.cmd("redrawstatus")
		end)
	)
	local cfg = vim.g.llama_config or {}
	local max_ms = (cfg.t_max_prompt_ms or 500) + (cfg.t_max_predict_ms or 1000) + 200
	timeout_timer = vim.uv.new_timer()
	timeout_timer:start(max_ms, 0, vim.schedule_wrap(clear))
end

function M.setup()
	vim.api.nvim_create_autocmd("CursorMovedI", {
		callback = function()
			local cfg = vim.g.llama_config
			if cfg and cfg.auto_fim and cfg.enable_at_startup then
				start()
			end
		end,
		desc = "llama.vim: start statusline spinner",
	})
	vim.api.nvim_create_autocmd({ "InsertLeavePre", "InsertLeave" }, {
		callback = clear,
		desc = "llama.vim: clear statusline spinner",
	})
end

return M
