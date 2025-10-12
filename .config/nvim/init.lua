---| Neovim Configuration -----------------------------------------
-- Modular configuration for Neovim
-- This file orchestrates loading all configuration modules

---| Bootstrap paq-nvim -------------------------------------------
-- Ensure paq-nvim is installed before trying to use it
require("bootstrap").ensure_paq()

---| Load Plugins ------------------------------------------------
-- Install plugins (paq declaration)
require("plugins")

---| Core Configuration -----------------------------------------
-- Load core settings in order
require("core.options")      -- vim.opt settings and diagnostics
require("core.autocommands") -- autocommands and autocmds
require("core.keymaps")      -- key mappings
require("core.functions")    -- helper functions

---| Plugin Configuration ---------------------------------------
-- Configure all plugins
require("plugins.config")
