-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    -- '3rd/image.nvim',
    -- {
    --   's1n7ax/nvim-window-picker',
    --   version = '2.*',
    --   config = function()
    --     require('nvim-window-picker').setup {
    --       filter_rules = {
    --         include_current_window = false,
    --         autoselect_one = true,
    --         bo = {
    --           filetype = {
    --             'neo-tree',
    --             'neo-tree-popup',
    --             'notify',
    --           },
    --           buftype = {
    --             'terminal',
    --             'quickfix',
    --           },
    --         },
    -- },
    -- }
    -- end,
    -- },
  },
  cmd = 'Neotree',
  keys = {
    { '<space>e', ':Neotree left<CR>', { desc = 'Reveal NeoTree [e]xplorer' } },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['<space>e'] = 'close_window',
        },
      },
    },
  },
}
