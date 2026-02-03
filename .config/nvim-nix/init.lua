-- Neovim 0.11.x Configuration (Nix-installed)
-- Modular configuration for stable Neovim
-- Uses paq-nvim for plugin management

--=============================================================================
-- Load Core Modules
--=============================================================================

-- Options must load first (sets leader key)
require('core.options')

-- Helper functions (global functions for statusline, toggles, etc.)
require('core.functions')

-- Plugin declarations (paq-nvim)
require('plugins-paq')

-- Keymaps (depends on functions module)
require('core.keymaps')

-- Autocommands
require('core.autocommands')

-- Plugin configurations (depends on plugins being loaded)
require('plugins-config')
