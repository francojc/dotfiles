return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    -- import cmp-nvim-lsp
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap

    -- autocmd to on attach
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {} ),
      callback = function(ev)

        -- keymaps
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show lsp references

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        -- note: conflict with vim keybinding for `gi`
        -- keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        -- note: conflict with vim keybinding for `gt`
        -- keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
      end,
    })

    -- enable autocompletion for each language server
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- add diagnostic signs
    local signs = {
      Error = "",
      Warn = "",
      Hint = "",
      Info = "",
    }

    for type, icon in pairs(signs) do
      local hl = "LspDiagnosticsSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- setup mason-lspconfig for language servers
    mason_lspconfig.setup_handlers({
      -- default
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["lua_ls"] = function()
        -- setup lua language server
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          filetypes = { "lua" },
        })
      end,
       ["r_language_server"] = function()
        -- setup r language server
        lspconfig["r_language_server"].setup({
          capabilities = capabilities,
          filetypes = { "r", "rmd", "quarto" },
          settings = {
            r = {
              lsp = {
                diagnostics = true,
                linters = {
                  line_length_linter = { line_length = 80 },
                  object_usage_linter = true,
                  object_name_linter = { style = "snake_case" },
                },
              },
            }
          }
        })
      end,
    })
    -- Filetype autocommand to show active LSP clients
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        vim.schedule(function()
          local bufnr = vim.api.nvim_get_current_buf()
          local file_type = vim.bo[bufnr].filetype
          -- Get active clients for the current buffer
          local active_clients = vim.lsp.get_clients({ bufnr = bufnr} )
          if #active_clients > 0 then
            local client_names = vim.tbl_map(function(client)
              return client.name
            end, active_clients)
            print(string.format("LSP active for %s: %s", file_type, table.concat(client_names, ", ")))
          else
            print(string.format("No LSP attached for %s", file_type))
          end
        end)
      end,
    })
   end,
}
