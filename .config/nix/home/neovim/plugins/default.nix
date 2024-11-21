{ pkgs, ... }: {
  # Plugins: more config
  imports = [
    ./alpha.nix
    ./bufferline.nix
    ./codecompanion.nix
    ./conform.nix
    ./fidget.nix
    ./lualine.nix
    ./lsp.nix
    ./lspsaga.nix
    ./none-ls.nix
    ./obsidian.nix
    ./slime.nix
    ./telescope.nix
    ./treesitter.nix
    ./which-key.nix
  ];

  # Plugins: basic config
  programs.nixvim = {
    colorschemes = {
      gruvbox = {
        enable = true;
        settings = {
          contrast_dark = "hard";
          contrast_light = "hard";
        };
      };
    };
    plugins = {
      auto-session.enable = true;
      avante = {
        enable = true;
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
      copilot-vim = { enable = true; };
      copilot-chat = {
        enable = true;
        settings = {
          answer_header = "  ";
          question_header = "  ";
          separator = "───";
          model = "gpt-4o";
          temperature = 0.3;
        };
      };
      dressing.enable = true;
      flash = {
        enable = true;
      };
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
        settings.signs = {
          add = { text = "│"; };
          change = { text = "│"; };
          delete = { text = "_"; };
          topdelete = { text = "‾"; };
          changedelete = { text = "~"; };
          untracked = { text = "┆"; };
        };
      };
      image = {
        enable = true;
        integrations = {
          markdown = {
            filetypes = [ "markdown" "quarto" "rmd" ];
            clearInInsertMode = true;
            onlyRenderImageAtCursor = true;
          };
        };
        maxHeightWindowPercentage = 20;
      };
      lazygit.enable = true;
      mini = {
        enable = true;
        modules = {
          indentscope = { };
          icons = { };
        };
      };
      nix.enable = true;
      notify = {
        enable = true;
        timeout = 3000;
        topDown = false;
      };
      nvim-autopairs.enable = true;
      nvim-colorizer = {
        enable = true;
        fileTypes = [ "*" ];
        userDefaultOptions = {
          mode = "virtualtext";
          virtualtext = "■";
          names = false;
          RGB = true;
          RRGGBB = true;
          RRGGBBAA = true;
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
      spectre.enable = true;
      todo-comments.enable = true;
      trouble.enable = true;
      vim-surround.enable = true;
      web-devicons.enable = true;
      yazi.enable = true;
    };

    # extraPlugins
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "aerial.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "stevearc";
          repo = "aerial.nvim";
          rev = "140f48fb068d21c02e753c63f7443649e55576f0";
          hash = "sha256-7Sj7Z5blJ6Qk/99EV4EBv4vdK1dHDGFL3W
RYLEnrRC0=";
        };
      })

      (pkgs.vimUtils.buildVimPlugin {
        name = "cmp-nvim-r";
        src = pkgs.fetchFromGitHub {
          owner = "jalvesaq";
          repo = "cmp-nvim-r";
          rev = "24f4d0e952332d8f6a420255a149815a7080849b";
          hash = "sha256-mBQX1dtXI7gI6mtkiRrQgloSERkfQV16egv3cwD0aok=";
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

      (pkgs.vimUtils.buildVimPlugin {
        name = "render-markdown";
        src = pkgs.fetchFromGitHub {
          owner = "MeanderingProgrammer";
          repo = "render-markdown.nvim";
          rev = "2f9d4f0be8784ed4fef5960eb7b80bf60c5fdf56";
          hash = "sha256-VCGAkcUIynRTErcGlaMWd+uo2KN1f3suPpGEimAhWHM=";
        };
      })
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

      -- cmp-r setup
      require("cmp_nvim_r").setup({
        filetypes = { "r", "quarto", "rmd" },
        quarto_intel = "~/.local/share/quarto/yaml-intelligence-resources.json"
      })

      -- Dropbar setup
      require("dropbar").setup({ })

      -- Quarto setup
      require("quarto").setup()

      -- Render markdown setup
      require('render-markdown').setup({
        bullet = {
          -- give a list of square bullets
          icons = { '■', '□', '◆', '◇' },
        },
        heading = {
          position = "inline",
        },
        file_types = { 'markdown', 'quarto', 'rmd', 'avante', 'copilot-chat' },
      })

      -- Yazi setup
      require("yazi").setup()

      -- Special keymapings
      -- Markdown
      vim.keymap.set("v", "<leader>mb", "c**<C-r>\"**<Esc>", { desc = "Bold", silent = true })
      vim.keymap.set("v", "<leader>mi", "c*<C-r>\"*<Esc>", { desc = "Italic", silent = true })
      vim.keymap.set("v", "<leader>ml", "c[<C-r>\"](<C-r>+)<Esc>", { desc = "Add Link", silent = true })
      vim.keymap.set("v", "<leader>mc", "c```\n<C-r>\"\n```<Esc>", { desc = "Code Block", silent = true })
      vim.keymap.set("v", "<leader>mk", "c`<C-r>\"`<Esc>", { desc = "Inline Code", silent = true })
      vim.keymap.set("n", "<leader>mt", "i- [ ] ", { desc = "Task Item", silent = true })
      vim.keymap.set("n", "<leader>mu", "i- ", { desc = "Unordered list item", silent = true })
      vim.keymap.set("v", "<leader>ms", "c~~<C-r>\"~~<Esc>", { desc = "Strikethrough", silent = true })
      vim.keymap.set("n", "<leader>m1", "i# ", { desc = "H1", silent = true })
      vim.keymap.set("n", "<leader>m2", "i## ", { desc = "H2", silent = true })
      vim.keymap.set("n", "<leader>m3", "i### ", { desc = "H3", silent = true })
    '';
  };
}
