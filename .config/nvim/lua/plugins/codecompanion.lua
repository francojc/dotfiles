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
        chat = { adapter = 'anthropic' },
        inline = { adapter = 'anthropic' },
        tools = { adapter = 'anthropic' },
      },
      -- adapters
      adapters = {
        anthropic = require('codecompanion.adapters').use('anthropic', {
          env = { api_key = 'ANTHROPIC_API_KEY' },
          schema = {
            model = { default = 'claude-3-5-sonnet-20240620' },
            temperature = { default = 0.5 },
          },
        }),
      },
      action_prompts = {
        ['General Assistant'] = {
          strategy = 'chat',
          name_f = function()
            return 'General Knowledge Assistant'
          end,
          description = 'Chat with a general knowledge assistant',
          opts = {
            index = 6, -- Adjust this number based on your existing prompts
            default_prompt = true,
            modes = { 'n', 'v' },
            mapping = '<LocalLeader>cg',
            auto_submit = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = 'system',
              content = [[You are a highly knowledgeable AI assistant capable of discussing a wide range of topics beyond just programming. Your expertise spans history, science, arts, culture, current events, and more. Provide concise, accurate, and helpful information on any subject the user asks about. If a topic is outside your knowledge base, politely say so. Always strive to give balanced and factual responses.]],
            },
            {
              role = 'user',
              condition = function(context)
                return not context.is_visual
              end,
              content = '\n \n',
            },
          },
        },
      },
    }

    -- setup codecompanion
    codecompanion.setup(config)
  end,
}
