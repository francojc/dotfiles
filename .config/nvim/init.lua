---| Neovim Configuration -----------------------------------------
-- Modular configuration for Neovim
-- This file orchestrates loading all configuration modules

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
