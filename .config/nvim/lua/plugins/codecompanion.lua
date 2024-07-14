return {
  enabled = true,
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    local codecompanion = require 'codecompanion'
    -- configuration
    local config = {
      -- strategies 
      strategies = {
        chat = { adapter = 'anthropic', },
        inline = { adapter = 'anthropic', },
        tools = { adapter = 'anthropic', },
      },
      -- adapters
      adapters = {
        anthropic = require('codecompanion.adapters').use('anthropic', {
          env = { api_key = 'ANTHROPIC_API_KEY', },
          schema = {
            model = { default = 'claude-3-5-sonnet-20240620', },
            temperature = { default = 0.5, },
          },
        }),
      },
    }

    -- setup codecompanion
    codecompanion.setup(config)
  end,
}
