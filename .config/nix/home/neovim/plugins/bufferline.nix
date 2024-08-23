{
  programs.nixvim = {
    plugins.bufferline = {
      enable = true;
      settings = {
        options.separator_style = "thin";
      };
    };
  };
}
