return {
  -- common dependencies
  { 'nvim-lua/plenary.nvim' },
  { 'vhyrro/luarocks.nvim',
    priority = 1000,
    opts = {
      rocks = { 'magick'},
    },
  },
}
