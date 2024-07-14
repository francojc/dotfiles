return {
  'mistricky/codesnap.nvim',
  build = 'make',
  keys = {
    { '<leader>cc', '<cmd>CodeSnap<cr>', mode = 'x', desc = 'Save selected code snapshot into clipboard' },
    { '<leader>cs', '<cmd>CodeSnapSave<cr>', mode = 'x', desc = 'Save selected code snapshot in ~/Screenshots/' },
  },
  opts = {
    save_path = '~/Screenshots/',
    has_breadcrumbs = false,
    has_line_number = true,
    bg_padding = 0,
    waternmark = "",
    min_width = 450,
  },
}

