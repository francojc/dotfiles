{
  programs.nixvim = {
    plugins.lspsaga = {
      enable = true;
      codeAction = {
        extendGitSigns = false;
        showServerName = true;
        onlyInCursor = true;
        keys = {
          exec = "<CR>";
          quit = [
            "<Esc>"
            "q"
          ];
        };
      };
      diagnostic = {
        diagnosticOnlyCurrent = false;
        showCodeAction = true;
      };
      lightbulb.virtualText = false;
      ui.codeAction = "";
    };
  };
}
