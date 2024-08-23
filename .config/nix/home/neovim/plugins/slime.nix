{
  programs.nixvim = {
    plugins.vim-slime = {
      enable = true;
      settings = {
        target = "kitty";
        preserve_curpos = false;
        bracketed_paste = true;
        default_config = {
          socket_name = "default";
        };
      };
    };
  };
}
