return {
  'nvim-lua/plenary.nvim',
  'christoomey/vim-tmux-navigator',
  {
    -- WARN: Luarocks is not working (see :checkhealth)
    'vhyrro/luarocks.nvim',
    priority = 100,
    opts = {
      rocks = {
        'magick',
      },
    },
  },
  -- WARN: May need config to modify the popup display
  {
    'stevearc/dressing.nvim',
    config = function()
      require('dressing').setup {
        input = {
          prefer_width = 0.50,
          win_options = {
            wrap = true,
          },
        },
        select = {
          enabled = true,
          backend = { 'telescope', 'fzf', 'builtin' },
        },
      }
    end,
  },
}
