{
  programs.nixvim = {
    plugins.bufferline = {
      enable = true;
      settings = {
        options = {
          separator_style = "thin";
          show_buffer_icons = false;
          color_icons = false;
          buffer_close_icon = ""; # ...
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
