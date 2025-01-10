{
  programs.nixvim = {
    plugins.bufferline = {
      enable = true;
      settings = {
        options = {
          separator_style = "thin";
          show_buffer_icons = false;
          color_icons = false;
          modified_icon = "";
          offsets = [
            {filetype = "NvimTree";}
            {text = "File Explorer";}
            {highlight = "Directory";}
            {separator = true;}
          ];
        };
      };
    };
  };
}
