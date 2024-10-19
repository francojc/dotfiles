{
  imports = [
    ./autocommands.nix
    ./completion.nix
    ./keymaps.nix
    ./options.nix
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    performance = {
      #   combinePlugins = {
      #     enable = true;
      #     standalonePlugins = [ ];
      #   };
      byteCompileLua.enable = true;
    };
    viAlias = true;
    vimAlias = false;
    luaLoader.enable = true;
  };
}
