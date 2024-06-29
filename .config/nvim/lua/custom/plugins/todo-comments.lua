return {
  'folke/todo-comments.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    highlight = {
      exclude = {
        'json',
        'js',
        'ts',
        'html',
        'tex',
      },
    },
  },
}
