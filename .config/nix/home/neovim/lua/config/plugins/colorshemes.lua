{
  "nightfox-nvim"
  enabled = nixCats('colorschemes') or false
  priority = 1000, -- high priority
  init = function()
    vim.cmd.colorscheme 'nightfox'
  end,
}
