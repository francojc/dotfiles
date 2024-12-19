{ pkgs, ... }:

{
  programs.nixvim = {
    plugins = {
      blink-cmp = {
        enable = true;
        settings = {
          keymap.preset = "enter";
          completion = {
            documentation = {
              auto_show = true;
              auto_show_delay_ms = 0;
            };
            list = {
              selection = "auto_insert";
            };
            menu = {
              draw = {
                gap = 2;
                treesitter = true;
                columns = [
                  {
                    __unkeyed-1 = "label";
                    __unkeyed-2 = "label_description";
                    gap = 1;
                  }
                  {
                    __unkeyed-1 = "kind_icon";
                    __unkeyed-2 = "kind";
                    gap = 1;
                  }
                ];
                components = {
                  label = {
                    width.fill = true;
                  };
                  "kind_icon" = {
                    width.fill = true;
                  };
                };
              };
            };
          };
          sources = {
            completion.enabled_providers = [
              "lsp"
              "path"
              "snippets"
              "buffer"
            ];
          };
        };
      };
    };
  };
}
