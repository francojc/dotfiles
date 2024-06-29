return {
  'ellisonleao/gruvbox.nvim',
  priority = 1000,
  config = function()
    local gruvbox = require 'gruvbox'
    gruvbox.setup {
      theme = 'dark',
      contrast = 'hard',
      sidebars = { 'qf', 'vista_kind', 'terminal', 'packer' },
      dark_float = true,
      dark_sidebar = true,
    }
    vim.cmd 'colorscheme gruvbox'
  end,
}
