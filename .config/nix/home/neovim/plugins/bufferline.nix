{
  programs.nixvim = {
    plugins.bufferline = {
      enable = true;
      settings = {
        options = {
          separator_style = "thin";
          show_buffer_icons = true;
          color_icons = false;
          buffer_close_icon = ""; # square x
          modified_icon = ""; # pencil
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
