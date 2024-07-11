return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    local cc = require 'codecompanion'

    cc.setup {
      -- strategies
      strategies = {
        chat = 'anthropic',
        inline = 'anthropic',
        tools = 'anthropic',
      },
      adapters = {
        anthropic = require('codecompanion.adapters').use('anthropic', {
          env = {
            api_key = 'ANTHROPIC_API_KEY',
          },
          schema = {
            model = {
              default = 'claude-3-5-sonnet-20240620',
            },
          },
        }),
      },
    }
  end,
}
