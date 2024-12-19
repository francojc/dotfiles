{
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true;
        capabilities = "capabilities = require('blink.cmp').get_lsp_capabilities(nil, true)";
        servers = {
          bashls.enable = true;
          lua_ls.enable = true;
          nil_ls.enable = true;
          nixd = {
            enable = true;
            cmd = [ "nixd" "--semantic-tokens=false" ];
            settings = {
              formatting = {
                command = [ "alejandra" ];
              };
            };
          };
          marksman = {
            enable = true;
            filetypes = [ "markdown" "quarto" ];
          };
          pyright = {
            enable = true;
            autostart = false;
            filetypes = [ "py" "python" "quarto" ];
            settings = {
              python = {
                analysis = {
                  autoSearchPaths = true;
                  diagnosticMode = "workspace";
                  useLibraryCodeForTypes = true;
                  typeCheckingMode = "basic";
                };
              };
            };
          };
          r_language_server = {
            enable = true;
            autostart = false;
            package = null;
            filetypes = [ "r" "quarto" "rmd" ];
          };
          yamlls.enable = true;
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
              action = "signature_help";
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

    extraConfigLua = "local lsp_active = false\n\nfunction _G.toggle_r_lsp()\n  local function get_local_r_path()\n    local handle = io.popen(\"nix develop --command which R 2>/dev/null\")\n    local result = handle:read(\"*a\")\n      handle:close()\n   return result:match(\"^%s*(.-)%s*$\")  -- trim any leading/trailing whitespace\n  end\n\n  local r_path = get_local_r_path()\n\n  if lsp_active then\n    -- Stop R LSP\n    vim.lsp.stop_client(vim.lsp.get_active_clients())\n    lsp_active = false\n    print(\"R LSP stopped\")\n  else\n    -- Start R LSP\n    require('lspconfig').r_language_server.setup{\n      cmd = {\n        string.format(\"%s\", r_path), \"--slave\", \"-e\", \"languageserver::run()\",\n      },\n      filetypes = { \"r\", \"quarto\" },\n      root_dir = require('lspconfig.util').root_pattern(\".git\", \"DESCRIPTION\"),\n    }\n    lsp_active = true\n    print(\"R LSP started\")\n  end\n end\n";
  };
}
