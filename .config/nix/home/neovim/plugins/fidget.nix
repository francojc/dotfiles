{
  programs.nixvim = {
    plugins.fidget = {
      enable = true;
      progress = {
        pollRate = 0;
        suppressOnInsert = true;
      };
    };
  };
}
