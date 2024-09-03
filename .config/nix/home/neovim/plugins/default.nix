{ pkgs, ... }:
{
  # Plugins: more config
  imports = [
    ./alpha.nix
    ./bufferline.nix
    ./codecompanion.nix
    ./copilot.nix
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
    colorschemes.gruvbox.enable = true;
    plugins = {
      conform-nvim.enable = true;
      dressing.enable = true;
      fidget.enable = true;
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
      markview = {
        enable = false;
        settings = {
          mode = [ "n" "x" ];
          hybrid_modes = [ "i" "r" ];
        };
      };
      mini = {
        enable = true;
        modules = {
          ai = { };
          surround = { };
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
      nvim-tree.enable = true;
      spectre.enable = true;
      todo-comments.enable = true;
      yazi.enable = true;
    };
    # extraPlugins
    extraPlugins = [
      { plugin = pkgs.vimPlugins.quarto-nvim; }
    ];

    # Lua config
    extraConfigLua = ''
      -- Quarto setup
      require("quarto").setup()
      -- Yazi setup
      require("yazi").setup()

      -- Toggle concellevel function
      function toggle_conceallevel()
        local current_level = vim.api.nvim_get_option('conceallevel')
        if current_level == 0 then
          vim.api.nvim_set_option('conceallevel', 1)
        else
          vim.api.nvim_set_option('conceallevel', 0)
        end
      end
    '';
  };
}
