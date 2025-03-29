{
  imports = [
    # ./autocommands.nix
    # ./completion.nix
    # ./keymaps.nix
    # ./lsp.nix
    # ./options.nix
    # ./plugins/default.nix
    # ./snippets.nix
  ];

  programs.nvf = {
    enable = true;
    settings = {
      vim.languages.nix.enable = true;
      vim.lsp.enable = true;
      vim.theme.enable = true;
      vim.theme.name = "gruvbox";
      vim.theme.background = "dark";
    };
  };
}
