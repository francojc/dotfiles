{
  plugins = {
    lsp-format = { enable = true; };
    lsp = {
      enable = true;
      servers = {
        eslint = { enable = true; };
        html = { enable = true; };
        lua-ls = { enable = true; };
        nil-ls = { enable = true; };
        marksman = {
          enable = true;
          filetypes = [ "markdown" "quarto" ];
        };
        pyright = { enable = true; };
        tsserver = { enable = false; };
        yamlls = { enable = true; };
        r-language-server = { enable = true; };
      };
      keymaps = {
        silent = true;
        lspBuf = {
          gd = {
            action = "definition";
            desc = "Goto Definition";
          };
          gr = {
            action = "references";
            desc = "Goto References";
          };
          gD = {
            action = "declaration";
            desc = "Goto Declaration";
          };
          gh = {
            action = "signature_help"; # added 08/02/2024
            desc = "Signature Help";
          };
          gI = {
            action = "implementation";
            desc = "Goto Implementation";
          };
          gT = {
            action = "type_definition";
            desc = "Type Definition";
          };
          K = {
            action = "hover";
            desc = "Hover";
          };
          "<leader>cw" = {
            action = "workspace_symbol";
            desc = "Workspace Symbol";
          };
          "<leader>cr" = {
            action = "rename";
            desc = "Rename";
          };
        };
        diagnostic = {
          "<leader>cd" = {
            action = "open_float";
            desc = "Line Diagnostics";
          };
          "[d" = {
            action = "goto_next";
            desc = "Next Diagnostic";
          };
          "]d" = {
            action = "goto_prev";
            desc = "Previous Diagnostic";
          };
        };
      };
    };
  };
  extraConfigLua = ''
       local _border = "rounded"

       vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
         vim.lsp.handlers.hover, {
           border = _border
         }
       )

       vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
         vim.lsp.handlers.signature_help, {
           border = _border
         }
       )

       vim.diagnostic.config{
         float={border=_border}
       };

       require('lspconfig.ui.windows').default_options = {
         border = _border
       }

    local function get_local_r_path()
      local handle = io.popen("nix develop --command which R 2>/dev/null")
      local result = handle:read("*a")
      handle:close()
      return result:match("^%s*(.-)%s*$")  -- trim any leading/trailing whitespace
    end

    local r_path = get_local_r_path()
    local lsp_active = false

    function _G.toggle_r_lsp()
      if lsp_active then
        -- Stop R LSP
        vim.lsp.stop_client(vim.lsp.get_active_clients())
        lsp_active = false
        print("R LSP stopped")
      else
        -- Start R LSP
        require('lspconfig').r_language_server.setup{
          cmd = {
            "sh", "-c",
            string.format("%s --slave -e 'languageserver::run()'", r_path)
          },
          filetypes = { "r", "quarto" },
          root_dir = require('lspconfig.util').root_pattern(".git", "DESCRIPTION"),
        }
        lsp_active = true
        print("R LSP started")
      end
     end
  '';
}
