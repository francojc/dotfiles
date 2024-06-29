-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<space>e', ':Neotree reveal<CR>', { desc = 'Reveal NeoTree [e]xplorer' } },
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
