-- Source markdown ftplugin settings
vim.cmd("runtime! ftplugin/markdown.lua")

-- Ensure ATX heading navigation works
vim.opt_local.define = "^\\s*#\\+\\s*"

-- Additional quarto-specific settings
vim.opt_local.textwidth = 0
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
