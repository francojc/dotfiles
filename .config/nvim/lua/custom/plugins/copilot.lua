-- Load the copilot plugin
return {
  -- github/copilot.vim
  'github/copilot.vim',
  -- other configs
  config = function()
    vim.keymap.set('i', '<C-D>', '<Plug>(copilot-accept-word)', { desc = 'Accept next word' })
    vim.keymap.set('i', '<C-F>', '<Plug>(copilot-accept-line)', { desc = 'Accept next line' })
  end,
}
