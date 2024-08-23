{
  programs.nixvim = {
    autoGroups = {
      "personal" = {clear = true;};
    };

    autoCmd = [
      {
        event = "TextYankPost";
        desc = "Highlight yanked text";
        group = "personal";
        callback.__raw = ''
          function()
            vim.highlight.on_yank()
          end
        '';
      }
      {
        event = "BufWritePre";
        desc = "Remove trailing whitespace on save";
        group = "personal";
        callback.__raw = ''
          function()
            vim.cmd('%s/\\s\\+$//e')
          end
        '';
      }
    ];
  };
}
