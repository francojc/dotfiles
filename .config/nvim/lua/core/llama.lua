---| Llama.vim Configuration -----------------------------
-- AI-powered code completion
-- using local llama.cpp server

local llama_api_key = vim.env.LLAMA_API_KEY
if not llama_api_key or llama_api_key == "" then
	vim.notify("llama.vim: LLAMA_API_KEY is unset; FIM requests will be rejected", vim.log.levels.WARN)
	llama_api_key = ""
end

vim.g.llama_config = {
	-- Behavior
	enable_at_startup = true,
	auto_fim = true,
	max_line_suffix = 8,
	-- Server connection
	endpoint_fim = "http://100.101.38.4:8080/infill",
	api_key = llama_api_key,
	model_fim = "ggml-org/Qwen2.5-Coder-3B-Q8_0-GGUF", -- added specific model
	-- Disable llama.vim instruction-editing mappings (FIM-only settings)
	keymap_inst_trigger = "",
	keymap_inst_rerun = "",
	keymap_inst_continue = "",
	keymap_inst_accept = "",
	keymap_inst_cancel = "",
	-- Context settings
	n_prefix = 512,
	n_suffix = 64,
	n_predict = 128,
	stop_strings_fim = {},
	-- Timeout settings
	t_max_prompt_ms = 1000,
	t_max_predict_ms = 1000,
	-- Cache settings
	max_cache_keys = 250,
	-- Ring buffer
	ring_n_chunks = 16,
	ring_chunk_size = 32,
	ring_scope = 1024,
	ring_update_ms = 1000,
	-- Keymaps
	keymap_fim_trigger = "<M-l>", -- Trigger FIM
	keymap_fim_accept_full = "<Tab>", -- Accept full
	keymap_fim_accept_line = "<C-F>", -- Accept line
	keymap_fim_accept_word = "<C-D>", -- Accept word
	-- Info
	show_info = 2, -- 0=off, 1=statusline, 2=inline
}

-- llama.vim's built-in :LlamaStatus always checks both FIM and instruction
-- endpoints. Replace it after plugin setup with an authenticated FIM-only check.
vim.schedule(function()
	vim.api.nvim_create_user_command("LlamaStatus", function()
		local config = vim.g.llama_config
		local models_url = config.endpoint_fim:gsub("/infill$", "") .. "/v1/models"
		local result = vim.system({
			"curl",
			"--silent",
			"--show-error",
			"--fail",
			"--max-time",
			"3",
			"--header",
			"Authorization: Bearer " .. config.api_key,
			"--url",
			models_url,
		}, { text = true }):wait()

		if result.code ~= 0 then
			vim.notify("FIM: unreachable (" .. vim.trim(result.stderr) .. ")", vim.log.levels.ERROR)
			return
		end

		local ok, response = pcall(vim.json.decode, result.stdout)
		local models = ok and response.data or nil
		if type(models) ~= "table" then
			vim.notify("FIM: invalid /v1/models response", vim.log.levels.ERROR)
			return
		end

		for _, model in ipairs(models) do
			if model.id == config.model_fim then
				vim.notify("FIM: ✅ Ready (" .. config.model_fim .. ")")
				return
			end
		end

		vim.notify("FIM: model not loaded (" .. config.model_fim .. ")", vim.log.levels.WARN)
	end, { desc = "Check authenticated FIM endpoint" })
end)
