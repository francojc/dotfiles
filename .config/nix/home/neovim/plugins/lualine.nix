{
  programs.nixvim = {
    plugins.lualine = {
      enable = true;
      globalstatus = false;
      disabledFiletypes = {
        statusline = [ "alpha" "NvimTree" "codecompanion" "copilot-chat" ];
      };
      componentSeparators = {
        left = "";
        right = "";
      };
      sectionSeparators = {
        left = "";
        right = "";
      };
      iconsEnabled = true;
      theme = "auto";
      sections = {
        lualine_a = [
          {
            name = "mode";
            fmt = "string.lower";
          }
        ];
        lualine_b = [
          {
            name = "branch";
            icon = "";
          }
          "diff"
        ];
        lualine_c = [
          {
            name = "diagnostic";
            extraConfig = {
              symbols = {
                error = " ";
                warn = " ";
                info = " ";
                hint = "󰝶 ";
              };
            };
          }
        ];
        lualine_x = [
          {
            name = "searchcount";
          }
          "selectioncount"
        ];
        lualine_y = [
          {
            name = "filetype";
          }
        ];
        lualine_z = [
          {
            name = "location";
          }
          "progress"
        ];
      };
    };
  };
}
