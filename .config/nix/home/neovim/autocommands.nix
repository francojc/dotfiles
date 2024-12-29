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
      {
        event = "TermOpen";
        desc = "Map colon to insert colon in terminal mode";
        group = "personal";
        callback.__raw = ''
          function()
            vim.api.nvim_buf_set_keymap(0, 't', ':', '<C-\\><C-n>:i', { noremap = true, silent = true })
          end
        '';
      }
    ];
  };
}
