if vim.g.vscode then
  -- VSCode extension
  require("francojc.core.vscode")
else
  --- Neovim configuration
  require("francojc.core.options")
  require("francojc.core.keymaps")
end


