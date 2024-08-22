{
  programs.nixvim = {
    plugins.copilot-lua = {
      enable = true;
      panel.enabled = false;
      filetypes = {
        csv = false;
        help = false;
        "*" = true;
      };
      suggestion = {
        enabled = true;
        autoTrigger = true;
        keymap = {
          accept = "<C-g>";
          acceptWord = "<C-d>";
          acceptLine = "<C-f>";
        };
      };
    };
  };
}
