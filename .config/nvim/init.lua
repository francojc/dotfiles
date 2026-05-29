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

---| Active Theme (read before plugin loading) ------------
-- Only the active colorscheme plugin loads eagerly; rest are opt.
-- theme-config.lua is managed by Nix home-manager.
local theme_config_path = vim.fn.stdpath("config") .. "/lua/theme-config.lua"
local ok, theme_config = pcall(dofile, theme_config_path)
vim.g.active_colorscheme = (ok and theme_config and theme_config.colorscheme) or "gruvbox"
-- Cache in package.loaded so require("theme-config") hits cache later
if ok and theme_config then
	package.loaded["theme-config"] = theme_config
end

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
