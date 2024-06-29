return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('ibl').setup {
        enabled = false,
        indent = {
          char = '│',
          smart_indent_cap = true,
        },
        scope = {
          enabled = false,
        },
      }
    end,
  },
}
