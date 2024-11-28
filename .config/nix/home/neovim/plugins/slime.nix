{
  programs.nixvim = {
    plugins.vim-slime = {
      enable = true;
      settings = {
        target = "kitty";
        # target = "wezterm";
        preserve_curpos = 0;
        bracketed_paste = 1;
        default_config = {
          socket_name = "default";
        };
      };
    };
  };
}
