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

      base16 = {
        enable = true;
        colorscheme = "gruvbox-dark-hard";
        # {
        # base00 = "#000000";
        # base01 = "#121212";
        # base02 = "#222222";
        # base03 = "#888888";
        # base04 = "#999999";
        # base05 = "#c1c1c1";
        # base06 = "#999999";
        # base07 = "#c1c1c1";
        # base08 = "#5f8787";
        # base09 = "#aaaaaa";
        # base0A = "#a06666";
        # base0B = "#dd9999";
        # base0C = "#aaaaaa";
        # base0D = "#888888";
        # base0E = "#999999";
        # base0F = "#b58900";
        # };
      };
      gruvbox = {
        enable = false;
        settings = {
          contrast_dark = "hard";
        };
      };
      nord = {
        enable = false;
      };
      one = {
        enable = false;
        settings = {
          allow_italics = 1;
        };
      };
      onedark = {
        enable = false;
      };
      vscode = {
        enable = false;
      };
    };
    plugins = {
      auto-session.enable = true;
      copilot-vim = {
        enable = true;
      };
      copilot-chat = {
        enable = true;
        settings = {
          answer_header = "## Copilot ----";
          question_header = "## Me ----";
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
          untracked = { text = "?"; };
        };
      };
      image = {
        enable = true;
        editorOnlyRenderWhenFocused = true;
        integrations = {
          markdown = {
            filetypes = [ "markdown" "quarto" "rmd" ];
            clearInInsertMode = true;
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
        file_types = { 'markdown', 'quarto', 'rmd' },
      })

      -- Yazi setup
      require("yazi").setup()
    '';
  };
}
