{
  # Plugins: more config
  imports = [
    ./alpha.nix
    ./bufferline.nix
    ./copilot.nix
    ./lualine.nix
    ./lsp.nix
    ./lspsaga.nix
    ./telescope.nix
    ./treesitter.nix
    ./which-key.nix
  ];

  # Plugins: basic config
  programs.nixvim = {
    colorschemes.gruvbox.enable = true;

    plugins = {
      mini = {
        enable = true;
        modules = {
          ai = { };
          surround = { };
          indentscope = { };
          icons = { };
          files = { };
        };
      };
      flash = {
        enable = true;
      };
      nvim-autopairs.enable = true;
      oil.enable = true;
    };
  };
}
