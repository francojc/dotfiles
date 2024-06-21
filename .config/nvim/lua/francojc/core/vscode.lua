-- Options for VSCode
local opt = vim.opt
-- Use the system clipboard
opt.clipboard:append("unnamedplus")
-- Use vscode clipboard
vim.g.clipboard = vim.g.vscode_clipboard

-- Add line numbers
opt.relativenumber = true -- add numbers relative to current position
opt.number = true -- add current line number

