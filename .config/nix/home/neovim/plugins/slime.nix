{
  programs.nixvim = {
    plugins.vim-slime = {
      enable = true;
      settings = {
        target = "kitty";
        preserve_curpos = 0;
        bracketed_paste = 1;
        default_config = {
          socket_name = "default";
        };
      };
    };
  };
}
