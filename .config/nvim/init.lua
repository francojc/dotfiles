---| Neovim Configuration -----------------------------------------
-- Modular configuration for Neovim
-- This file orchestrates loading all configuration modules

---| Providers --------------------------------------
--- Disable
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

---| Llama.vim ----------------------------------
-- AI-powered code completion using local llama.cpp server
vim.g.llama_config = {
  -- Behavior
  enable_at_startup = true,
  auto_fim = true,
  max_line_suffix = 8,
  -- Server connection
  endpoint_fim = "http://100.101.38.4:8080/infill",
  api_key = "de7df50cff8b8ed12426b5d2af443c6644a356f7359ca6ba5d221b23b7339ec1",
  model_fim = "",
  -- Context settings
  n_prefix = 512,
  n_suffix = 64,
  n_predict = 128,
  stop_strings = {},
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
  keymap_fim_trigger = "<C-N>",    -- Trigger FIM
  keymap_fim_accept_full = "<Tab>", -- Accept full
  keymap_fim_accept_line = "<C-F>", -- Accept line
  keymap_fim_accept_word = "<C-D>", -- Accept word
  -- Info
  show_info = 2, -- 0=off, 1=statusline, 2=inline
}

---| Plugin Management (vim.pack) ---------------------------------
-- Install and declare plugins using Neovim 0.12+ native vim.pack
-- This automatically installs missing plugins on first run
require("plugins-pack")

---| Core Configuration -----------------------------------------
-- Load core settings in order
require("core.options") -- vim.opt settings and diagnostics
require("core.functions") -- helper functions
require("core.autocommands") -- autocommands and autocmds
require("core.keymaps") -- key mappings

---| Plugin Configuration ---------------------------------------
-- Configure eager-loaded plugins
require("plugins-config")
