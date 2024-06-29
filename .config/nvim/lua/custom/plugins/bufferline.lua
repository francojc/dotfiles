return {
  'akinsho/bufferline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  version = '*',
  config = function()
    require('bufferline').setup {
      options = {
        mode = 'tabs',
        themable = true,
        numbers = 'ordinal',
      },
    }
  end,
}
