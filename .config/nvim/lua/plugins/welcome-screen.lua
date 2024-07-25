return {
  -- dashboard to greet
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require 'alpha'
      local dashboard = require 'alpha.themes.dashboard'

      -- Set header
      -- dashboard.section.header.val = {}

      -- Set menu
      dashboard.section.buttons.val = {
        dashboard.button('e', '  > New file', ':ene <BAR> startinsert <CR>'),
        dashboard.button('f', '󰈞  > Find file', ':Telescope find_files<CR>'),
        dashboard.button('y', '  > Yazi explorer', '<cmd>lua require("yazi").yazi()<CR>'),
        dashboard.button('r', '  > Recent', ':Telescope oldfiles<CR>'),
        dashboard.button('s', '  > Settings', ':e $MYVIMRC | :cd %:p:h<cr>'),
        dashboard.button('q', '󰅚  > Quit NVIM', ':qa<CR>'),
      }

      local fortune = require 'alpha.fortune'
      dashboard.section.footer.val = fortune {
        fortune_list = {
          { 'Perfect is the enemy of good.' },
          { 'Uncertainty is the only certainty.' },
          { 'Happiness is not in the future.' },
          { 'Worry serves no purpose.' }
        },
      }

      -- Send config to alpha
      alpha.setup(dashboard.opts)
    end,
  },
}
