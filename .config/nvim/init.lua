---| Neovim Configuration -----------------------------------------
-- Modular configuration for Neovim
-- This file orchestrates loading all configuration modules

---| Providers --------------------------------------
--- Disable
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

---| Completion ----------------------------------
-- copilot.vim is the default inline completion (keymaps bound after blink.cmp).
-- llama.vim (local llama.cpp FIM) stays installed but starts disabled.
require("core.copilot").pre_load()
require("core.llama")

---| Active Theme (read before plugin loading) ------------
-- Follows Omarchy's active theme (lua/omarchy-theme.lua). Only the active
-- colorscheme plugin loads eagerly; the rest are opt.
vim.g.active_colorscheme = require("omarchy-theme").colorscheme()

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
require("core.copilot").keymaps() -- after blink.cmp so our <Tab> wins
