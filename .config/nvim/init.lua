-- This is the main entry point of the application require("francojc.core")
require("francojc.lazy")

-- Function to reload the configuration
function _G.ReloadConfig()
  for name,_ in pairs(package.loaded) do
    if name:match('^user') or name:match('^plugins') then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

-- Command to reload the configuration
vim.api.nvim_create_user_command('ReloadConfig', ReloadConfig, {})
