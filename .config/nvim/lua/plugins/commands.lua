---| Command-triggered plugins -------------------------------------
-- These plugins are lazy-loaded when specific commands are invoked
-- lz.n will automatically merge this with other plugin specs

return {
  -- LazyGit
  {
    "lazygit.nvim",
    cmd = { "LazyGit", "LazyGitLog" },
    -- No setup needed for lazygit.nvim
  },

  -- Yazi file manager
  {
    "yazi.nvim",
    cmd = "Yazi",
    after = function()
      require("yazi").setup({})
    end,
  },

  -- Terminal
  {
    "toggleterm.nvim",
    cmd = "ToggleTerm",
    after = function()
      require("toggleterm").setup({})
    end,
  },

  -- Code outline
  {
    "aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialPrev", "AerialNext" },
    after = function()
      require("aerial").setup({
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      })
    end,
  },

  -- Todo comments
  {
    "todo-comments.nvim",
    cmd = { "TodoFzfLua", "TodoTelescope", "TodoTrouble", "TodoQuickFix", "TodoLocList" },
    after = function()
      require("todo-comments").setup({})
    end,
  },

  -- CSV toggle
  {
    "csvview.nvim",
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
    after = function()
      require("csvview").setup({})
    end,
  },
}
