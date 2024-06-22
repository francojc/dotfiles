return {
    -- lsp package manager
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      -- import mason
      local mason = require("mason")
      -- import mason-lspconfig
      local mason_lspconfig = require("mason-lspconfig")
      -- import tool installer
      local mason_tool_installer = require("mason-tool-installer")

      -- setup mason config
      mason.setup({
        ui = {
          icons = {
            package_installed = "",
            package_uninstalled = "",
            package_pending = "",
          },
        },
      })

      mason_lspconfig.setup({
        -- list of language servers to install
        ensure_installed = {
          "lua_ls",
          "r_language_server",
          "yamlls",
          "bashls",
          "dockerls",
          "cssls",
          "jedi_language_server",
        }
      })

      -- setup tool installer
      mason_tool_installer.setup({
        -- list of tools to install
        ensure_installed = {
          "prettier",
          "black",
          "pylint",
          "stylua",
          "vale",
          "yamlfmt",
          "stylua",
        },
      })
  end,
}

