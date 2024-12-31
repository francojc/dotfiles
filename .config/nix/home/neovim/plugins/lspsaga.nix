{
  programs.nixvim = {
    plugins.lspsaga = {
      enable = true;
      beacon = {
        enable = true;
      };
      codeAction = {
        extendGitSigns = false;
        showServerName = true;
        onlyInCursor = true;
        numShortcut = true;
        keys = {
          exec = "<CR>";
          quit = [
            "<Esc>"
            "q"
          ];
        };
      };
      diagnostic = {
        borderFollow = true;
        diagnosticOnlyCurrent = false;
        showCodeAction = true;
      };
      lightbulb = {
        enable = false;
        sign = false;
        virtualText = true;
      };
      symbolInWinbar.enable = false;
      ui = {
        border = "rounded";
        codeAction = "💡";
      };
    };
  };
}
