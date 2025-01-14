{
  imports = [
    ./autocommands.nix
    ./completion.nix
    ./keymaps.nix
    ./lsp.nix
    ./options.nix
    ./plugins/default.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    performance = {
      byteCompileLua.enable = true;
    };
    viAlias = true;
    vimAlias = false;
    luaLoader.enable = true;
  };
}
