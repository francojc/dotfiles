{
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        enableLuaLoader = true;

        # Autocommands ---------------------------------------------
        autocmds = [
          {
            enable = false;
            event = "TextYankPost";
            desc = "Highlight yanked text";
            group = "personal";
            callback = ":lua
              function()
                vim.highlight.on_yank()
              end
            ";
          }
        ];

        # Assistant -------------------------------------------------
        assistant = {
          codecompanion-nvim = {
            enable = true;
            # setup codecompanion
          };
          copilot = {
            enable = true;
            mappings = {
              suggestion = {
                # TODO: find out how to auto-enable suggestions (:Copilot suggestions)
                acceptLine = "<C-f>";
                acceptWord = "<C-d>";
                next = "<C-]";
                prev = "<C-[";
                dismiss = "<C-e>";
              };
            };
            setupOpts = {
              suggestion = {
                auto_trigger = true;
              };
            };
          };
        };

        # Dashboards -------------------------------------------------
        dashboard = {
          startify = {
            enable = true;
          };
        };

        # Diagnostics ------------------------------------------------
        diagnostics = {
          nvim-lint = {
            enable = true;
            lint_after_save = true;
          };
        };

        # Filetree ---------------------------------------------------

        # Formatters -------------------------------------------------
        formatter = {
          conform-nvim = {
            enable = true;
            setupOpts = {
              format_on_save = {
                lsp_format = "fallback";
                timeout_ms = 500;
              };
              formatters_by_ft = {
                python = ["black"];
                r = ["styler"];
                lua = ["stylua"];
                bash = ["shfmt"];
                javascript = ["prettier"];
                css = ["prettier"];
                html = ["prettier"];
                nix = ["alejandra"];
              };
            };
          };
        };

        # Keymaps -----------------------------------------------------
        keymaps = [
          # General -----
          {
            mode = "i";
            key = "jj";
            action = "<Esc>";
            desc = "Use jj as <Esc>";
            silent = true;
          }
          {
            mode = "n";
            key = "<Esc>";
            action = "<Esc><Cmd>nohlsearch<CR>";
            desc = "Clear search highlight";
          }
          # Movement -----
          {
            mode = "n";
            key = "j";
            action = "v:count == 0 ? 'gj' : 'j'";
            expr = true;
            desc = "Move cursor down visual line";
          }
          {
            mode = "n";
            key = "k";
            action = "v:count == 0 ? 'gk' : 'k'";
            expr = true;
            desc = "Move cursor up visual line";
          }
          {
            mode = "n";
            key = "<C-h>";
            action = "<C-w>h";
            desc = "Move to left window";
          }
          {
            mode = "n";
            key = "<C-j>";
            action = "<C-w>j";
            desc = "Move to bottom window";
          }
          {
            mode = "n";
            key = "<C-k>";
            action = "<C-w>k";
            desc = "Move to top window";
          }
          {
            mode = "n";
            key = "<C-l>";
            action = "<C-w>l";
            desc = "Move to right window";
          }
          # Files -----
          # ...
        ];

        # LSP --------------------------------------------------------
        languages = {
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          nix.enable = true;
          markdown.enable = true;

          bash.enable = true;
          css.enable = true;
          html.enable = true;
          python.enable = true;
          r.enable = true;
        };

        # Options ---------------------------------------------------
        options = {
          breakindent = true;
          expandtab = true;
          linebreak = true;
          shiftwidth = 2;
          showbreak = "↳";
          showmode = false;
          tabstop = 2;
          winborder = "rounded";
        };

        statusline = {
          lualine = {
            enable = true;
          };
        };

        # Tabline -------------------------------------------------
        tabline = {
          nvimBufferline = {
            enable = true;
          };
        };

        # Terminal -----------------------------------------------
        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = true;
          };
        };

        # Themes ---------------------------------------------------
        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };

        # Visuals -----------------------------------------------
        visuals = {
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          fidget-nvim.enable = true;
          highlight-undo.enable = true;
        };

        # Plugins -----------------------------------------------
        autopairs.nvim-autopairs.enable = true;

        fzf-lua = {
          enable = true;
          profile = "fzf-native";
        };

        mini = {
          icons.enable = true;
          indentscope.enable = true;
          surround.enable = true;
        };
      };
    };
  };
}
