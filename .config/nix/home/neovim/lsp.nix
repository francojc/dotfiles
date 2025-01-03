{
  username,
  hostname,
  ...
}: {
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true;
        keymaps = {
          silent = true;
          diagnostic = {
            "[d" = {
              action = "goto_next";
              desc = "LSP: Next Diagnostic";
            };
            "]d" = {
              action = "goto_prev";
              desc = "LSP: Previous Diagnostic";
            };
            "<leader>cd" = {
              action = "open_float";
              desc = "Line Diagnostics";
            };
          };
          lspBuf = {
            "<leader>cr" = {
              action = "rename";
              desc = "Rename";
            };
            "<leader>cw" = {
              action = "workspace_symbol";
              desc = "Workspace Symbol";
            };
            gD = {
              action = "declaration";
              desc = "LSP: Goto Declaration";
            };
            gd = {
              action = "definition";
              desc = "LSP: Goto Definition";
            };
            gs = {
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
            gr = {
              action = "references";
              desc = "LSP: Goto References";
            };
            K = {
              action = "hover";
              desc = "LSP: Hover";
            };
          };
        };
        servers = {
          bashls.enable = false;
          lua_ls.enable = true;
          marksman = {
            enable = true;
            filetypes = ["markdown" "quarto"];
          };
          nil_ls.enable = true;
          nixd = {
            enable = true;
            cmd = ["nixd" "--semantic-tokens=false"];
            extraOptions.offset_encoding = "utf-8"; # nixvim #2390
            settings = {
              expr = "import <nixpkgs> {}";
              formatting = {
                command = ["alejandra"];
              };
              options = {
                nixos.expr = "(builtins.getFlake \"/Users/${username}/.dotfiles/.config/nix\").nixosConfigurations.${hostname}.options";
                home-manager.expr = "(builtins.getFlake \"/Users/${username}/.dotfiles/.config/nix\").homeConfigurations.${username}.options";
              };
            };
          };
          pyright = {
            enable = true;
            autostart = true;
            filetypes = ["py" "python"];
            settings = {
              python = {
                analysis = {
                  autoSearchPaths = true;
                  diagnosticMode = "workspace";
                  typeCheckingMode = "basic";
                  useLibraryCodeForTypes = true;
                };
              };
            };
          };
          r_language_server = {
            enable = true;
            autostart = false;
            filetypes = ["r" "quarto" "rmd"];
            package = null;
          };
          ruff = {
            enable = true;
          };
          yamlls = {
            enable = true;
            autostart = false;
          };
        };
      };
      lspkind = {
        enable = true;
        cmp.enable = true;
      };
      lsp-format = {
        enable = true;
        lspServersToEnable = "all";
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
