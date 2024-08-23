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
      lazygit = {
        enable = true;
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
          RGB = true;
          RRGGBB = true;
          RRGGBBAA = true;
        };
      };
      nvim-tree.enable = true;
      spectre.enable = true;
      todo-comments.enable = true;
      yazi = {
        enable = true;
      };
    };
    # Lua config
    extraConfigLua = ''
      require("yazi").setup()
    '';
  };
}
