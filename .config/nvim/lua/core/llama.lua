---| Llama.vim Configuration -----------------------------
-- AI-powered code completion using local llama.cpp server

local llama_api_key = vim.env.LLAMA_API_KEY or ""
vim.g.llama_config = {
	-- Behavior
	enable_at_startup = true,
	auto_fim = true,
	max_line_suffix = 8,
	-- Server connection
	endpoint_fim = "http://100.101.38.4:8080/infill",
	api_key = llama_api_key,
	model_fim = "",
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
