---| Key/Event-triggered plugins -----------------------------------
-- These plugins are lazy-loaded on specific keys or events
-- lz.n will automatically merge this with other plugin specs

return {
  -- Flash jump (load on search keys)
  {
    "flash.nvim",
    keys = {
      { "<leader>sf", mode = { "n", "x", "o" } },
      { "<leader>sF", mode = { "n", "x", "o" } },
    },
    after = function()
      require("flash").setup({})
    end,
  },

  -- Gitsigns (load when opening files in git repos)
  {
    "gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    after = function()
      require("gitsigns").setup()
    end,
  },
}
