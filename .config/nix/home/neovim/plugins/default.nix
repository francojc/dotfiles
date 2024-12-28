{pkgs, ...}: {
  # Plugins: more config
  imports = [
    ./alpha.nix
    ./bufferline.nix
    ./conform.nix
    ./fidget.nix
    ./lualine.nix
    ./lspsaga.nix
    ./none-ls.nix
    ./obsidian.nix
    ./slime.nix
    ./treesitter.nix
    ./which-key.nix
  ];

  # Plugins: basic config
  programs.nixvim = {
    colorschemes = {
      gruvbox = {
        enable = false;
        settings = {
          contrast_dark = "hard";
          contrast_light = "hard";
        };
      };
      onedark = {
        enable = true;
        settings = {
          style = "warmer";
        };
      };
    };
    plugins = {
      auto-session = {
        enable = true;
        settings = {
          bypass_save_filetypes = ["alpha" "NvimTree" "term"];
        };
      };
      avante = {
        enable = false;
        settings = {
          hints.enabled = true;
          provider = "copilot";
          claude = {
            endpoint = "https://api.anthropic.com";
            max_tokens = 4096;
            model = "claude-3-5-sonnet-latest";
            temperature = 0.3;
          };
          copilot = {
            model = "claude-3.5-sonnet";
          };
          windows = {
            wrap = true;
            sidebar_header = {
              enabled = true;
              align = "right";
              rounded = false;
            };
          };
        };
      };
      cmp-pandoc-nvim.enable = true;
      copilot-vim = {enable = true;};
      copilot-chat = {
        enable = true;
        settings = {
          answer_header = "  ";
          error_header = "  ";
          question_header = "  ";
          separator = "───";
          model = "claude-3.5-sonnet";
          temperature = 0.3;
        };
      };
      diffview.enable = true;
      dressing.enable = true;
      flash = {
        enable = true;
      };
      fzf-lua = {
        enable = true;
      };
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
        settings.signs = {
          add = {text = "│";};
          change = {text = "│";};
          delete = {text = "_";};
          topdelete = {text = "‾";};
          changedelete = {text = "~";};
          untracked = {text = "┆";};
        };
      };
      image = {
        enable = true;
        integrations = {
          markdown = {
            filetypes = ["markdown" "quarto" "rmd"];
            clearInInsertMode = true;
            onlyRenderImageAtCursor = true;
          };
        };
        maxHeightWindowPercentage = 25;
      };
      lazygit.enable = true;
      mini = {
        enable = true;
        modules = {
          indentscope = {};
          icons = {};
        };
      };
      nix.enable = true;
      notify = {
        enable = true;
        timeout = 3000;
        topDown = false;
      };
      nvim-autopairs.enable = true;
      colorizer = {
        enable = true;
        settings = {
          filetypes = ["*"];
          user_default_options = {
            mode = "virtualtext";
            virtualtext = "■";
            names = false;
            RGB = true;
            RRGGBB = true;
            RRGGBBAA = true;
          };
        };
      };
      nvim-tree = {
        enable = true;
        view.side = "left";
        hijackCursor = true;
        modified.enable = true;
        renderer = {
          highlightGit = true;
          rootFolderLabel = false;
          icons = {
            gitPlacement = "signcolumn";
            modifiedPlacement = "signcolumn";
          };
        };
      };
      otter.enable = true;
      render-markdown = {
        enable = true;
        settings = {
          bullet = {
            icons = ["■" "□" "◆" "◇"];
            right_pad = 1;
          };
          code = {
            code = {
              above = " ";
              below = " ";
              border = "thick";
              language_pad = 2;
              position = "right";
              right_pad = 2;
              sign = false;
              width = "block";
            };
          };
          heading = {
            border = true;
            position = "inline";
            icons = [
              "1| "
              "2| "
              "3| "
              "4| "
              "5| "
              "6| "
            ];
            sign = false;
            width = "full";
          };
          render_modes = true;
          signs.enabled = false;
          file_types = ["markdown" "quarto" "rmd" "copilot-chat"];
          win_options = {
            conceallevel.rendered = 0;
          };
        };
      };

      spectre.enable = true;
      todo-comments.enable = true;
      toggleterm.enable = true;
      trouble.enable = true;
      vim-surround.enable = true;
      web-devicons.enable = true;
      yazi.enable = true;
    };

    # extraPlugins
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
          name = "aerial.nvim";
          src =
            pkgs.fetchFromGitHub {
              owner = "stevearc";
              repo = "aerial.nvim";
              rev = "140f48fb068d21c02e753c63f7443649e55576f0";
              hash = "sha256-7Sj7Z5blJ6Qk/99EV4EBv4vdK1dHDGFL3W
RYLEnrRC0=";
            };
        })

      (pkgs.vimUtils.buildVimPlugin {
        name = "aider.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "aweis89";
          repo = "aider.nvim";
          rev = "9c70158a8966d717f7a7b9d7d045e44662f0f2a1";
          hash = "sha256-GBwgGI6wvu52hdwRoVkJEfaecSUSr+/qMYxYAy75Hv8=";
        };
      })

      (pkgs.vimUtils.buildVimPlugin {
        name = "dropbar.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "Bekaboo";
          repo = "dropbar.nvim";
          rev = "669e325489202ae4da5a951314bbf8dbb20e7cff";
          hash = "sha256-3VdwHC4/ti6QCCrb6ciRDYxk6+EIgrcLN0vmQYn00RQ=";
        };
      })

      pkgs.vimPlugins.quarto-nvim
    ];

    # Lua config
    extraConfigLua = ''
      -- Aerial setup
      require("aerial").setup({
        on_attach = function(bufnr)
          -- jump forward and backward
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
        -- keymap to toggle the aerial window
        vim.keymap.set("n", "<leader>\\o", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial" })
      })

      -- Aider setup
      require("aider").setup({
        watch_files = true,
        spawn_on_startup = false,
        fzf_action_key = "ctrl-x",
        notify = require("fidget").notify,
        aider_args = {},
        -- after_update_hook = function() require("diffview").open({'HEAD^'}) end,
        model_picker_search = { "^anthropic/", "^openai/", "^gemini" },
        focus_on_spawn = false,
        auto_scroll = false,
        dark_mode = false,
        on_term_open = function()
          local function tmap(key, val)
            local opt = { buffer = 0 }
            vim.keymap.set("t", key, val, opt)
          end
          -- exit insert mode
          tmap("<Esc>", "<C-\\><C-n>")
          tmap("jj", "<C-\\><C-n>")
          -- enter command mode
          tmap(":", "<C-\\><C-n>:")
          -- scrolling up/down
          tmap("<C-u>", "<C-\\><C-n><C-u>")
          tmap("<C-d>", "<C-\\><C-n><C-d>")
          -- remove line numbers
          vim.wo.number = false
          vim.wo.relativenumber = false
        end,
        win = {
          direction = "vertical",
        },
      })

      -- cmp-pandoc setup
      require("cmp_pandoc").setup({
        -- @type: table of strings
        filetypes = { "markdown", "quarto", "rmd" },
        bibliography =  {
          documentation = true,
          fields = {
            "author",
            "title",
            "year"
          },
        },
        crossref = {
          documentation = true,
        },
      })

      -- Dropbar setup
      require("dropbar").setup()

      -- Quarto setup
      require("quarto").setup({
        debug = false,
        closePreviewOnExit = true,
        lspFeatures = {
          enabled = true,
          languages = { "r", "python", "bash", "html" },
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
          enabled = true,
          },
        },
      })

      -- Keymaps for navigating terminal windows
      vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h')
      vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j')
      vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k')
      vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l')

      -- Special keymapings
      -- Markdown --

      -- Unordered list
      vim.keymap.set("n", "<leader>mu", "i- ", { desc = "Unordered list item", silent = true })
      vim.keymap.set("v", "<leader>mu", ":s/^/- /<CR>gv", { desc = "Unordered list item", silent = true })

      -- Task list
      vim.keymap.set("n", "<leader>mt", "i- [ ] ", { desc = "Task item", silent = true })
      vim.keymap.set("v", "<leader>mt", ":s/^/- [ ] /<CR>gv", { desc = "Task jtem", silent = true })

      -- Styled text
      vim.keymap.set("v", "<leader>mb", "c**<C-r>\"**<Esc>", { desc = "Bold", silent = true })
      vim.keymap.set("v", "<leader>mi", "c*<C-r>\"*<Esc>", { desc = "Italic", silent = true })
      vim.keymap.set({"n", "v"}, "<leader>ms", "c~~<C-r>\"~~<Esc>", { desc = "Strikethrough", silent = true })

      -- Links
      vim.keymap.set("v", "<leader>ml", "c[<C-r>\"](<C-r>+)<Esc>", { desc = "Add Link", silent = true })

      -- Code blocks
      vim.keymap.set("v", "<leader>mc", "c```\n<C-r>\"\n```<Esc>", { desc = "Code Block", silent = true })
      vim.keymap.set("v", "<leader>mk", "c`<C-r>\"`<Esc>", { desc = "Inline Code", silent = true })

      -- Headers
      vim.keymap.set({"n", "v"}, "<leader>m1", "I# ", { desc = "H1", silent = true })
      vim.keymap.set({"n", "v"}, "<leader>m2", "I## ", { desc = "H2", silent = true })
      vim.keymap.set({"n", "v"}, "<leader>m3", "I### ", { desc = "H3", silent = true })
    '';
  };
}
