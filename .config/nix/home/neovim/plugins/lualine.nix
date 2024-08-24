{
  programs.nixvim = {
    plugins.lualine = {
      enable = true;
      iconsEnabled = true;
      theme = "auto";
      globalstatus = false;
      disabledFiletypes = {
        statusline = [ "alpha" "NvimTree" "codecompanion" "copilot-chat" ];
      };
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
        ];
        lualine_y = [
          {
            name = "filetype";
            extraConfig = {
              icon_only = true;
            };
            separator.left = "";
          }
        ];
        lualine_z = [
          {
            name = "location";
          }
        ];
      };
    };
  };
}
