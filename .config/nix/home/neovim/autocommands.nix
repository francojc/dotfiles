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
        event = ["TextYankPost" "ModeChanged"];
        desc = "Remove extra inner whitespace from selection";
        group = "personal";
        callback.__raw = ''
          function()
            -- Only proceed if in visual mode or just left visual mode
            if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' or vim.v.event.old_mode == 'v' or vim.v.event.old_mode == 'V' then
              local start_pos = vim.fn.getpos("'<")
              local end_pos = vim.fn.getpos("'>")

              -- Ensure we have valid positions
              if start_pos and end_pos then
                -- Get the selected lines
                local start_line = start_pos[2]
                local end_line = end_pos[2]

                -- Apply the substitution only to the selected range
                vim.cmd(string.format("%d,%ds/\\s\\+/ /g", start_line, end_line))
              end
            end
          end
        '';
      }
    ];
  };
}
