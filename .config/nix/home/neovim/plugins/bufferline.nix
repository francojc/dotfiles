{
  programs.nixvim = {
    plugins.bufferline = {
      enable = true;
      settings = {
        options = {
          separator_style = "thin"; # "thin" | "thick" | "slant" | "round" | "default"
          modified_icon = "✎"; # pencil
          color_icons = false;
          show_buffer_icons = false;
        };
      };
    };
  };
}
