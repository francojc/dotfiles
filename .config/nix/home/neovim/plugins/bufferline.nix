{
  programs.nixvim = {
    plugins.bufferline = {
      enable = true;
      settings = {
        highlights = {
          fill = { fg = "#252525"; bg = "#252525"; };
          close_button = { fg = "#252525"; bg = "#252525"; };
          background = { fg = "#888888"; bg = "#252525"; };
          buffer_selected.bg = "#000000";
        };

        options = {
          separator_style = "thin";
          show_buffer_icons = true;
          color_icons = true;
          buffer_close_icon = ""; # square x
          max_prefix_length = 25;
          modified_icon = ""; # pencil
          offsets = [
            { filetype = "NvimTree"; }
            { text = "File Explorer"; }
            { highlight = "Directory"; }
            { separator = true; }
          ];
        };
      };
    };
  };
}
