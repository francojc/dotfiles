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
require("core.llama")

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
