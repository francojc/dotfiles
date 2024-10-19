{
  programs.nixvim = {
    plugins = {
      lsp-format = { enable = true; };
      lsp-signature = { enable = true; };
      lsp-status = { enable = true; };
      lspkind = { enable = true; };
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          lua_ls.enable = true;
          nil_ls.enable = true;
          marksman = {
            enable = true;
            filetypes = [ "markdown" "quarto" ];
          };
          pyright.enable = false;
          yamlls.enable = false;
          r_language_server.enable = false;
        };
        keymaps = {
          silent = true;
          lspBuf = {
            gd = {
              action = "definition";
              desc = "LSP: Goto Definition";
            };
            gr = {
              action = "references";
              desc = "LSP: Goto References";
            };
            gD = {
              action = "declaration";
              desc = "LSP: Goto Declaration";
            };
            gh = {
              action = "signature_help"; # added 08/02/2024
              desc = "LSP: Signature Help";
            };
            gI = {
              action = "implementation";
              desc = "LSP: Goto Implementation";
            };
            gT = {
              action = "type_definition";
              desc = "LSP: Type Definition";
            };
            K = {
              action = "hover";
              desc = "LSP: Hover";
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
              desc = "LSP: Next Diagnostic";
            };
            "]d" = {
              action = "goto_prev";
              desc = "LSP: Previous Diagnostic";
            };
          };
        };
      };
    };

    extraConfigLua = ''
      local lsp_active = false

      function _G.toggle_r_lsp()
        local function get_local_r_path()
          local handle = io.popen("nix develop --command which R 2>/dev/null")
          local result = handle:read("*a")
            handle:close()
         return result:match("^%s*(.-)%s*$")  -- trim any leading/trailing whitespace
        end

        local r_path = get_local_r_path()

        if lsp_active then
          -- Stop R LSP
          vim.lsp.stop_client(vim.lsp.get_active_clients())
          lsp_active = false
          print("R LSP stopped")
        else
          -- Start R LSP
          require('lspconfig').r_language_server.setup{
            cmd = {
              string.format("%s", r_path), "--slave", "-e", "languageserver::run()",
            },
            filetypes = { "r", "quarto" },
            root_dir = require('lspconfig.util').root_pattern(".git", "DESCRIPTION"),
          }
          lsp_active = true
          print("R LSP started")
        end
       end
    '';
  };
}
