return{
  "nvim-treesitter/nvim-treesitter",
  config = function()
    local nvimtreesitter = require("nvim-treesitter")
    -- setup nvim-treesitter
    nvimtreesitter.setup({
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

    })
  end
}




