return {
  'R-nvim/R.nvim',
  lazy = false,
  config = function()
    local opts = {
      R_app = 'radian',
      pdfviewer = '',
      Rout_more_colors = true,
      bracketed_paste = true,
      -- In Neovim, only alphabetic letters can be mapped with CTRL key
      assignment_keymap = '<C-I>o',
      pipe_keymap = '<C-I>p',
    }
    require('r').setup(opts)
  end,
}
