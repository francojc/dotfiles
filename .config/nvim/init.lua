---| Neovim Configuration -----------------------------------------
-- Modular configuration for Neovim
-- This file orchestrates loading all configuration modules
--
---| Llama.vim ----------------------------------
-- AI-powered code completion using local llama.cpp server
vim.g.llama_config = {
	endpoint_fim = "http://100.101.38.4:8080/infill",
	api_key = "de7df50cff8b8ed12426b5d2af443c6644a356f7359ca6ba5d221b23b7339ec1",
	model_fim = "",
	n_prefix = 256,
	n_suffix = 64,
	n_predict = 128,
	stop_strings = {},
	t_max_prompt_ms = 500,
	t_max_predict_ms = 1000,
	show_info = 2, -- inline info
	auto_fim = true,
	max_line_suffix = 8, -- num chars after stop suggesting fills
	max_cache_keys = 250,
	ring_n_chunks = 16,
	ring_chunk_size = 64,
	ring_scope = 1024,
	ring_update_ms = 1000,
	keymap_fim_trigger = "<C-N>",
	keymap_fim_accept_full = "<Tab>",
	keymap_fim_accept_line = "<C-F>",
	keymap_fim_accept_word = "<C-D>",
	enable_at_startup = false,
}

-- Llama.vim highlights: modify these as needed
vim.api.nvim_set_hl(0, "llama_hl_hint", { fg = "#918374", ctermfg = 59 }) -- Custom color
vim.api.nvim_set_hl(0, "llama_hl_info", { fg = "#B9BB25", ctermfg = 119 }) -- Custom color

---| Plugin Management (vim.pack) ---------------------------------
-- Install and declare plugins using Neovim 0.12+ native vim.pack
-- This automatically installs missing plugins on first run
require("plugins-pack")

---| Core Configuration -----------------------------------------
-- Load core settings in order
require("core.options") -- vim.opt settings and diagnostics
require("core.autocommands") -- autocommands and autocmds
require("core.keymaps") -- key mappings
require("core.functions") -- helper functions

---| Plugin Configuration ---------------------------------------
-- Configure eager-loaded plugins
require("plugins-config")
