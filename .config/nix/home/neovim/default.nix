{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.generators) mkLuaInline;
in {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        enableLuaLoader = true;

        # Autocommands ---------------------------------------------
        autocmds = [
          {
            enable = true;
            event = ["TextYankPost"];
            desc = "Highlight yanked text";
            callback = mkLuaInline ''
              function()
                vim.highlight.on_yank()
              end
            '';
          }
          {
            enable = true;
            event = ["LspAttach"];
            desc = "Nvim default LSP completion";
            callback = mkLuaInline ''
              function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if client.supports_method("textDocument/completion") then
                  vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
                end
              end
            '';
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

        # Autocompletion ------------------------------------------

        autocomplete = {
          blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
            setupOpts = {
              keymap = {
                "<C-space>" = ["show" "show_signature" "hide_signature" "fallback"];
                "<C-e>" = ["hide"];
                "<CR>" = ["accept" "fallback"];
                "<Tab>" = ["snippet_forward" "fallback"];
                "<S-Tab>" = ["snippet_backward" "fallback"];
                "<C-j>" = ["select_next" "fallback"];
                "<C-k>" = ["select_prev" "fallback"];
              };
              sources = {
                default = ["path" "snippets"];
              };
            };
          };
        };

        # Binds ------------------------------------------------------
        binds = {
          whichKey = {
            enable = true;
            setupOpts = {
              preset = "helix";
            };
          };
          cheatsheet = {
            enable = true;
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
        filetree = {
          neo-tree = {
            enable = true;
          };
        };

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
                "*" = ["trim_whitespace" "squeeze_blanks"];
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
            action = "<Esc><Cmd>nohlsearch<Cr>";
            desc = "Clear search highlight";
          }
          {
            mode = ["n" "v"];
            key = "gl";
            action = "g_";
            desc = "Move to last non-blank character";
          }
          {
            mode = "n";
            key = "<leader>y";
            action = "ggVGy";
            desc = "Yank entire file";
          }
          # Buffers -----
          {
            mode = "n";
            key = "<leader>bb";
            action = "<Cmd>e #<Cr>";
            desc = "Switch to other buffer";
          }
          {
            mode = "n";
            key = "<Tab>";
            action = "<Cmd>BufferLineCycleNext<Cr>";
            desc = "Next buffer";
          }
          {
            mode = "n";
            key = "<S-Tab>";
            action = "<Cmd>BufferLineCyclePrev<Cr>";
            desc = "Previous buffer";
          }
          {
            mode = "n";
            key = "<leader>bd";
            action = "<Cmd>BufferLinePickClose<Cr>";
            desc = "Delete buffer";
          }
          {
            mode = "n";
            key = "<leader>bo";
            action = "<Cmd>BufferLineCloseOthers<Cr>";
            desc = "Close other buffers";
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

          # Filetree -----
          {
            mode = "n";
            key = "|";
            action = "<Cmd>Neotree position=left focus<Cr>";
            desc = "Toggle filetree";
          }

          # Find -----
          {
            mode = "n";
            key = "<leader>ff";
            action = "<Cmd>lua require('fzf-lua').files()<Cr>";
            desc = "Find files";
          }
          {
            mode = "n";
            key = "<leader>fg";
            action = "<Cmd>lua require('fzf-lua').live_grep()<Cr>";
            desc = "Live grep";
          }
          {
            mode = "n";
            key = "<leader>fb";
            action = "<Cmd>lua require('fzf-lua').buffers()<Cr>";
            desc = "Find buffers";
          }
          {
            mode = "n";
            key = "<leader>fh";
            action = "<Cmd>lua require('fzf-lua').help_tags()<Cr>";
            desc = "Find help tags";
          }

          # Terminal -----
          {
            mode = "n";
            key = "<leader>tt";
            action = "<Cmd>ToggleTerm<Cr>";
            desc = "Toggle terminal";
          }
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
          clipboard = "unnamedplus";
          expandtab = true;
          linebreak = true;
          scrolloff = 3;
          shiftwidth = 2;
          showbreak = "↳";
          showmode = false;
          sidescrolloff = 5;
          tabstop = 2;
          winborder = "rounded";
          pumheight = 0;
          spell = false;
          spelllang = "en_us";
          spellfile = "${config.home.homeDirectory}/.spell/en.utf-8.add"; # Use config variable
          smartindent = true;
          ignorecase = true;
          smartcase = true;
          swapfile = false;
          backup = false;
          undofile = true;
          signcolumn = "yes";
          cursorline = true;
          cursorlineopt = "number";
        };

        statusline = {
          lualine = {
            enable = true;
          };
        };

        # Snippets -----------------------------------------------
        snippets = {
          luasnip = {
            enable = true;
            setupOpts = {
              enable_autosnippets = true;
            };
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
            lazygit = {
              enable = true;
              direction = "float";
            };
            setupOpts = {
              winbar.name_formatter = {
                _type = "lua-inline";
                expr = ''
                  function()
                    return require("nvim-web-devicons").get_icon("terminal") .. " Terminal "
                  end
                '';
              };
              auto_scroll = true;
            };
          };
        };

        # Themes ---------------------------------------------------
        theme = {
          enable = true;
          name = "tokyonight";
          style = "night";
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

        # Extra plugins ------------------------------------------
        extraPlugins = {
          render-markdown.package = pkgs.vimPlugins.render-markdown-nvim;
          render-markdown.setup = "
              require('render-markdown').setup({})

            ";
        };
      };
    };
  };
}
