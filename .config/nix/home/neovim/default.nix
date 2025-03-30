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
        assistant = { };

        # Autocompletion ------------------------------------------
        autocomplete = { };

        # Binds ------------------------------------------------------
        binds = {
          whichKey = {
            enable = true;
            setupOpts = {
              preset = "helix";
            };
          };
        };

        # Dashboards -------------------------------------------------
        dashboard = {
          dashboard-nvim = {
            enable = false;
            setupOpts = {
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
        diagnostics = { };

        # Filetree ---------------------------------------------------
        filetree = { };

        # Formatters -------------------------------------------------
        formatter = { };

        # Git --------------------------------------------------------
        git = { };

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
        languages = { };

        # Notes ------------------------------------------------------
        notes = { };

        # Notfications -----------------------------------------------
        notify = { };

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
        session = { };

        # Snippets -----------------------------------------------
        snippets = { };

        # Tabline -------------------------------------------------
        tabline = {
          nvimBufferline = {
            enable = true;
          };
        };

        # Terminal -----------------------------------------------
        terminal = { };

        # UI ---------------------------------------------------
        ui = { };

        # Utility -----------------------------------------------
        utility = { };

        # Visuals -----------------------------------------------
        visuals = { };

        # Plugins -----------------------------------------------
        fzf-lua = {
          enable = true;
          profile = "fzf-native";
        };

        mini = {
          icons.enable = false;
          indentscope.enable = false;
          surround.enable = false;
        };

        # Extra plugins ------------------------------------------

        extraPlugins = with pkgs.vimPlugins; {
          # # Flash
          # flash = {
          #   package = flash-nvim;
          #   setup = "require('flash').setup()";
          # };
          #
          # # Friendly Snippets
          # friendly-snippets = {
          #   package = friendly-snippets;
          #   setup = "
          #     require('luasnip.loaders.from_vscode').lazy_load()
          #   ";
          # };
          #
          # # Nightfox
          # nightfox = {
          #   package = nightfox-nvim;
          #   setup = "
          #   require('nightfox').setup({
          #     options = {
          #       styles = {
          #         comments = 'italic',
          #        },
          #     },
          #   })
          #   vim.cmd('colorscheme nightfox')
          #   ";
          # };
          #
          # # Slime
          # slime = {
          #   package = vim-slime;
          #   setup = "
          #     vim.g.slime_target = 'neovim'
          #     vim.g.slime_bracketed_paste = 1
          #     ";
          # };

          #
        };
      };
    };
  };
}
