-- add keymaps 
local on_attach = function(_, bufnr)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
  vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {})
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
end

return {
  -- add the necessary repositories
  {
    "williamboman/mason.nvim",
    config = function()
      local mason = require("mason")

      mason.setup({
        -- change_detection = {
        --   notify = false,
        -- },
      })
    end,
},
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      local masonlspconfig = require("mason-lspconfig")

      masonlspconfig.setup({
        ensure_installed = {
          "lua_ls",
          "r_language_server",
          "yamlls",
       }
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- lspconfig.lua_ls.setup {}
      -- Enable the following language servers
      local servers = {
        "lua_ls",
        "r_language_server",
        "yamlls",
        "bashls",
        "dockerls",
        "cssls",
        "jedi_language_server",
      }

      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          on_attach = on_attach
        })
      end
    end,
  },
}
