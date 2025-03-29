{
  config, # Added config to access homeDirectory
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
            # Neovim 0.11: Default mappings [d and ]d navigate diagnostics.
            # You might prefer these over fzf-lua mappings below (<leader>ld, <leader>lD).
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
            # Neovim 0.11: Default mapping 'grn' for rename.
            # "<leader>cr" = {
            #   action = "rename";
            #   desc = "Rename";
            # };
            "<leader>cw" = {
              action = "workspace_symbol";
              desc = "Workspace Symbol";
            };
            # Neovim 0.11: Default mapping 'gD' for declaration.
            gD = {
              action = "declaration";
              desc = "LSP: Goto Declaration";
            };
            # Neovim 0.11: Default mapping 'gd' for definition.
            gd = {
              action = "definition";
              desc = "LSP: Goto Definition";
            };
            # Neovim 0.11: Default mapping 'CTRL-S' (Insert/Select) for signature help.
            gs = {
              action = "signature_help";
              desc = "LSP: Signature Help";
            };
            # Neovim 0.11: Default mapping 'gri' for implementation.
            # gI = {
            #   action = "implementation";
            #   desc = "LSP: Goto Implementation";
            # };
            # Neovim 0.11: Default mapping 'gT' for type definition.
            gT = {
              action = "type_definition";
              desc = "LSP: Type Definition";
            };
            # Neovim 0.11: Default mapping 'grr' for references.
            # gr = {
            #   action = "references";
            #   desc = "LSP: Goto References";
            # };
            # Neovim 0.11: Default mapping 'K' for hover.
            K = {
              action = "hover";
              desc = "LSP: Hover";
            };
            # Neovim 0.11: Default mapping 'gra' (Normal/Visual) for code action.
            # See keymaps.nix for <leader>ca mapping using fzf-lua.
          };
        };
        servers = {
          bashls = {
            enable = true;
            autostart = false;
          };
          lua_ls = {
            enable = true;
            autostart = false;
          };
          marksman = {
            enable = true;
            autostart = true;
            filetypes = ["markdown" "quarto"];
          };
          nil_ls = {
            enable = true;
            autostart = false;
          };
          nixd = {
            enable = true;
            # cmd = ["nixd" "--semantic-tokens=false"];
            cmd = ["nixd"];
            # extraOptions.offset_encoding = "utf-8"; # nixvim #2390
            settings = {
              expr = "import <nixpkgs> {}";
              formatting = {
                command = ["alejandra"];
              };
              options = {
                # Use config variables for paths
                nixos.expr = "(builtins.getFlake \"${config.home.homeDirectory}/.dotfiles/.config/nix\").nixosConfigurations.${hostname}.options";
                home-manager.expr = "(builtins.getFlake \"${config.home.homeDirectory}/.dotfiles/.config/nix\").homeConfigurations.${username}.options";
              };
            };
          };
          pyright = {
            enable = true;
            autostart = false;
            filetypes = ["py" "python" "quarto"];
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
            autostart = false; # Managed by toggle function below
            filetypes = ["r" "quarto" "rmd"];
            package = null; # Assumes R is in the environment path
          };
          ruff = {
            enable = true;
            autostart = false;
            filetypes = ["py" "python" "quarto"];
          };
          yamlls = {
            enable = true;
            autostart = false;
          };
        };
      };
      lspkind = {
        enable = true;
        cmp.enable = true; # Assuming this integrates with blink-cmp or is needed by it
      };
      # Removed lsp-format as conform-nvim is used in plugins/default.nix
      # lsp-format = {
      #   enable = true;
      #   lspServersToEnable = "all";
      # };
    };
    extraConfigLua = ''
      -- This function uses lspconfig directly. Neovim 0.11 introduces vim.lsp.config/enable,
      -- but for a dynamic toggle like this, using lspconfig might still be the easiest way.
      -- Consider exploring if vim.lsp.enable/disable could replace this if desired.
      local r_lsp_active = false

      function _G.toggle_r_lsp()
        local clients = vim.lsp.get_active_clients({ name = "r_language_server" })

        if #clients > 0 then
          -- Stop R LSP
          for _, client in ipairs(clients) do
            vim.lsp.stop_client(client.id)
          end
          r_lsp_active = false
          print("R LSP stopped")
        else
          -- Start R LSP
          -- Attempt to find R from the Nix environment path
          local r_path_handle = io.popen("command -v R 2>/dev/null")
          local r_path = r_path_handle:read("*a")
          r_path_handle:close()
          r_path = vim.trim(r_path) -- Trim whitespace

          if r_path == "" then
            print("Error: R executable not found in PATH.")
            return
          end

          require('lspconfig').r_language_server.setup{
            cmd = {
              r_path, "--slave", "-e", "languageserver::run()",
            },
            filetypes = { "r", "quarto", "rmd" },
            root_dir = require('lspconfig.util').root_pattern(".git", "DESCRIPTION", ".Rproj"), -- Added .Rproj
          }
          -- Attempt to attach to current buffer if it's an R filetype
          local current_buf = vim.api.nvim_get_current_buf()
          local current_ft = vim.bo[current_buf].filetype
          if vim.tbl_contains({"r", "quarto", "rmd"}, current_ft) then
             vim.lsp.start_client({ name = "r_language_server", bufnr = current_buf })
          end
          r_lsp_active = true
          print("R LSP started using: " .. r_path)
        end
      end
    '';
  };
}
