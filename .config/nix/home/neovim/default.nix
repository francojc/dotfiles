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
        preventJunkFiles = true;
        vimAlias = false;

        # Autocommands ---------------------------------------------
        autocmds = [
          {
            enable = false;
            event = ["TextYankPost"];
            desc = "Highlight yanked text";
            callback = mkLuaInline ''
              function()
                vim.highlight.on_yank()
              end
            '';
          }
          {
            enable = false;
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
            enable = false;
            # setup codecompanion with:
            # - copilot w/ sonnet
            # - gemini pro 2.5
          };
          copilot = {
            enable = false;
            mappings = {
              suggestion = {
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
          nvim-cmp = {
            enable = false;
          };
        };

        # Binds ------------------------------------------------------
        binds = {
          whichKey = {
            enable = true;
            setupOpts = {
              preset = "modern";
            };
          };
        };

        # Dashboards -------------------------------------------------
        dashboard = {
          dashboard-nvim = {
            enable = false;
            setupOpts = {
              # adapted from nvf logo (https://github.com/NotAShelf/nvf)
              # under CC-BY (https://creativecommons.org/licenses/by/4.0/)
              config.header = [
                "   🭇🭄🭏🬼          🬿    "
                "  🭊🭁██🭌🬿         █🭏🬼  "
                "  🭥🭒████🭏🬼       ██🭌🬿 "
                "λ  🭢🭕████🭌🬿      ████🭏"
                "VλV  🭥🭒████🭏🬼    █████"
                "λVλVλ 🭢🭕████🭌🬿   █████"
                "VλV󱄅    🭥🭒████🭏🬼 🭕████"
                "λVλVλ    🭢🭕████🭌🬿 🭥🭒██"
                "V󱄅 λV      🭥🭒████🭏🬼🭢🭕🭠"
                "λVλVλ       🭢🭕████🭌🬿  "
                "  VλV         🭥🭒██🭝🭚  "
                "    λ          🭢🭕🭠🭗   "
                ""
              ];
            };
          };
        };

        # Diagnostics ------------------------------------------------
        diagnostics = {
          nvim-lint = {
            enable = false;
            lint_after_save = true;
          };
        };

        # Filetree ---------------------------------------------------
        filetree = {
          neo-tree = {
            enable = false;
          };
        };

        # Formatters -------------------------------------------------
        formatter = {
          conform-nvim = {
            enable = false;
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

        # Git --------------------------------------------------------
        git = {
          enable = false;
          gitsigns.enable = false;
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
            action = "<Cmd>Neotree position=left focus toggle<Cr>";
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
          {
            mode = "n";
            key = "<leader>fr";
            action = "<Cmd>lua require('fzf-lua').oldfiles()<Cr>";
            desc = "Find recent files";
          }

          # Terminal -----
          {
            mode = "n";
            key = "<leader>tt";
            action = "<Cmd>ToggleTerm<Cr>";
            desc = "Toggle terminal";
          }
          {
            mode = "n";
            key = "<C-c>";
            action = "<Plug>SlimeParagraphSend<Cr>";
            desc = "Send code phrase to terminal";
          }
          {
            mode = "x";
            key = "<C-c>";
            action = "<Plug>SlimeRegionSend<Cr>";
            desc = "Send code region to terminal";
          }
          {
            mode = "t";
            key = "<C-h>";
            action = "<C-\\><C-n><C-w>h";
            desc = "Move to left window";
          }
          {
            mode = "t";
            key = "<C-j>";
            action = "<C-\\><C-n><C-w>j";
            desc = "Move to bottom window";
          }
          {
            mode = "t";
            key = "<C-k>";
            action = "<C-\\><C-n><C-w>k";
            desc = "Move to top window";
          }
          {
            mode = "t";
            key = "<C-l>";
            action = "<C-\\><C-n><C-w>l";
            desc = "Move to right window";
          }
          {
            mode = "t";
            key = "jj";
            action = "<C-\\><C-n>";
            desc = "Esc from terminal";
          }
        ];

        # LSP --------------------------------------------------------
        languages = {
          enableLSP = false;
          enableFormat = false;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          nix.enable = true;
          lua.enable = true;
          markdown = {
            enable = true;
            extensions.render-markdown-nvim = {
              enable = true;
              setupOpts = {
                bullet = {
                  enabled = true;
                  icons = ["■ " "□ " "▪ " "▫ "];
                };
                completions = {
                  lsp.enabled = true;
                };
                dash.enabled = false;
                file_types = ["markdown" "quarto" "CodeCompanion"];
                heading = {
                  icons = ["# " "## " "### " "#### " "##### " "###### "];
                };
                html.comment.conceal = false;
                latex.enabled = false;
              };
            };
          };
          bash.enable = true;
          css.enable = true;
          html.enable = true;
          python.enable = true;
          r.enable = true;
        };

        # Notes ------------------------------------------------------
        notes = {
          todo-comments.enable = false;
        };

        # Notfications -----------------------------------------------
        notify = {
          nvim-notify.enable = false;
        };

        # Options ---------------------------------------------------
        options = {
          backup = false;
          breakindent = true;
          clipboard = "unnamedplus";
          cursorline = true;
          cursorlineopt = "number";
          expandtab = true;
          ignorecase = true;
          linebreak = true;
          scrolloff = 3;
          shiftwidth = 2;
          showbreak = "↳";
          showmode = false;
          sidescrolloff = 5;
          signcolumn = "yes";
          smartcase = true;
          smartindent = true;
          spell = false;
          spellfile = "${config.home.homeDirectory}/.spell/en.utf-8.add"; # Use config variable
          spelllang = "en_us";
          tabstop = 2;
          undofile = true;
          winborder = "rounded";
        };

        statusline = {
          lualine = {
            enable = true;
          };
        };

        # Sessions -----------------------------------------------
        session = {
          nvim-session-manager.enable = false;
        };

        # Snippets -----------------------------------------------
        snippets = {
          luasnip = {
            enable = false;
            setupOpts = {
              enable_autosnippets = true;
            };
          };
        };

        # Tabline -------------------------------------------------
        tabline = {
          nvimBufferline = {
            enable = false;
          };
        };

        # Terminal -----------------------------------------------
        terminal = {
          toggleterm = {
            enable = false;
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

        # UI ---------------------------------------------------
        ui = {
          borders.enable = false;
          colorizer.enable = false;
        };

        # Utility -----------------------------------------------
        utility = {
          images = {
            image-nvim = {
              enable = false;
              setupOpts = {
                backend = "kitty";
                integrations = {
                  markdown = {
                    clearInInsertMode = true;
                    filetypes = ["markdown" "quarto"];
                  };
                };
              };
            };
          };
          outline = {
            aerial-nvim = {
              enable = false;
              mappings.toggle = "<leader>\\o";
            };
          };
        };

        # Visuals -----------------------------------------------
        visuals = {
          fidget-nvim.enable = false;
          highlight-undo.enable = false;
          nvim-cursorline.enable = false;
          nvim-scrollbar.enable = false;
          nvim-web-devicons.enable = false;
        };

        # Plugins -----------------------------------------------
        autopairs.nvim-autopairs.enable = false;

        fzf-lua = {
          enable = true;
          profile = "fzf-native";
        };

        mini = {
          icons.enable = false;
          indentscope.enable = false;
          surround.enable = false;
        };

        treesitter = {
          enable = false;
          context.enable = false;
          mappings.incrementalSelection = {
            init = "<C-space>";
            incrementByNode = "<C-space>";
            decrementByNode = "<Bs>";
          };
        };

        # Extra plugins ------------------------------------------

        extraPlugins = with pkgs.vimPlugins; {
          # Flash
          flash = {
            package = flash-nvim;
            setup = "require('flash').setup()";
          };

          # Friendly Snippets
          friendly-snippets = {
            package = friendly-snippets;
            setup = "
              require('luasnip.loaders.from_vscode').lazy_load()
            ";
          };

          # Nightfox
          nightfox = {
            package = nightfox-nvim;
            setup = "
            require('nightfox').setup({
              options = {
                styles = {
                  comments = 'italic',
                 },
              },
            })
            vim.cmd('colorscheme nightfox')
            ";
          };

          # Slime
          slime = {
            package = vim-slime;
            setup = "
              vim.g.slime_target = 'neovim'
              vim.g.slime_bracketed_paste = 1
              ";
          };

          #
        };
      };
    };
  };
}
