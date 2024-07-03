return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim', -- Optional
  },
  config = function()
    local codecompanion = require 'codecompanion'
    codecompanion.setup {
      display = {
        show_settings = false,
        action_palette = {
          width = 95,
          height = 10,
        },
        chat = {
          window = {
            layout = 'vertical',
            width = 0.35,
          },
          show_settings = false,
        },
      },
      -- Strategies
      strategies = {
        chat = 'anthropic',
        inline = 'anthropic',
        tools = 'anthropic',
      },
      -- Adapters
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
      }, -- Actions (added to the palette)
      actions = {
        {
          name = 'Academic Advisor',
          strategy = 'chat',
          description = 'Get advice on various academic topics',
          opts = {
            modes = { 'n', 'v' },
            auto_submit = false,
            user_prompt = true,
          },
          prompts = {
            {
              role = 'system',
              content = [[You are a well-rounded academic advisor with expertise in various fields including linguistics, psychology, philosophy, computer science, and programming. Provide insightful advice and explanations on topics from these fields. Keep your responses concise yet informative.]],
            },
            {
              role = 'user',
              content = function(context)
                if context.mode == 'v' then
                  local text = require('codecompanion.helpers.code').get_code(context.start_line, context.end_line)
                  return 'I have selected the following text:\n\n```\n' .. text .. '\n```\n\nPlease provide advice or insights related to this text.'
                else
                  return "I'm seeking advice or insights on an academic topic. Might you be able to help?"
                end
              end,
            },
          },
        },
        {
          name = 'Code advisor',
          strategy = 'chat',
          description = 'Get some special GenAI advice',
          opts = {
            modes = { 'v' },
            auto_submit = true,
            user_prompt = true,
          },
          prompts = {
            {
              role = 'system',
              content = function(context)
                return 'I want you to act as a senior '
                  .. context.filetype
                  .. ' developer. I will ask you specific questions and I want you to return concise explanations and codeblock examples.'
              end,
            },
            {
              role = 'user',
              contains_code = true,
              content = function(context)
                local text = require('codecompanion.helpers.code').get_code(context.start_line, context.end_line)

                return 'I have the following code:\n\n```' .. context.filetype .. '\n' .. text .. '\n```\n\n'
              end,
            },
          },
        },
      },
    }
  end,
}
