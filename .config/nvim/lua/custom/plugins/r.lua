return {
  'R-nvim/R.nvim',
  lazy = false,
  config = function()
    local opts = {
      R_app = 'radian',
      pdfviewer = '',
      Rout_more_colors = true,
      bracketed_paste = true,
      assignment_keymap = '<C-I>o',
      pipe_keymap = '<C-I>p',
    }
    require('r').setup(opts)
  end,
}
