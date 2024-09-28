{ pkgs, ... }: {
  # Plugins: more config
  imports = [
    ./alpha.nix
    ./bufferline.nix
    ./codecompanion.nix
    ./conform.nix
    ./copilot.nix
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
    colorschemes.one = {
      enable = true;
      settings = {
        allow_italics = true;
      };
    };
    plugins = {
      dressing.enable = true;
      flash.enable = true;
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
        backend = "kitty";
        integrations = {
          markdown = {
            filetypes = [ "markdown" "quarto" "vimwiki" ];
          };
        };
      };
      lazygit.enable = true;
      mini = {
        enable = true;
        modules = {
          indentscope = { };
          icons = { };
        };
      };
      notify.enable = true;
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
        view = {
          side = "right";
        };
      };
      spectre.enable = true;
      todo-comments.enable = true;
      yazi.enable = true;
    };

    # extraPlugins
    extraPlugins = [
      # pkgs.vimPlugins.neoformat
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
      -- Render markdown setup
      require('render-markdown').setup({
        file_types = { 'markdown', 'quarto' },
      })
      -- Yazi setup
      require("yazi").setup()
      -- Quarto setup
      require("quarto").setup()

      -- Toggle concellevel function
      function _G.toggle_conceallevel()
        local current_level = vim.api.nvim_get_option('conceallevel')
        if current_level == 0 then
          vim.api.nvim_set_option('conceallevel', 1)
        else
          vim.api.nvim_set_option('conceallevel', 0)
        end
      end

      -- keymap
      vim.api.nvim_set_keymap('n', '<leader>\\c', 'toggle_conceallevel()<CR>', { noremap = true, silent = true })
    '';
  };
}
