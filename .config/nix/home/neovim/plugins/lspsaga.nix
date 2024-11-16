{
  programs.nixvim = {
    plugins.lspsaga = {
      enable = true;
      ui = {
        border = "rounded";
        codeAction = "💡";
      };
      lightbulb = {
        enable = false;
        sign = true;
        virtualText = true;
      };
      symbolInWinbar.enable = false;
    };
  };
}
