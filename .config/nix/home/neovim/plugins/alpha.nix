{
  programs.nixvim = {
    plugins.alpha = let
      nixFlake = [
        "                                              "
        " ███    ██ ██ ██   ██ ██    ██ ██ ███    ███  "
        " ████   ██ ██  ██ ██  ██    ██ ██ ████  ████  "
        " ██ ██  ██ ██   ███   ██    ██ ██ ██ ████ ██  "
        " ██  ██ ██ ██  ██ ██   ██  ██  ██ ██  ██  ██  "
        " ██   ████ ██ ██   ██   ████   ██ ██      ██  "
        "                                              "
      ];
    in {
      enable = true;
      layout = [
        {
          type = "padding";
          val = 4;
        }
        {
          opts = {
            hl = "AlphaHeader";
            position = "center";
          };
          type = "text";
          val = nixFlake;
        }
        {
          type = "padding";
          val = 2;
        }
        {
          type = "group";
          val = let
            mkButton = shortcut: cmd: val: hl: {
              type = "button";
              inherit val;
              opts = {
                inherit hl shortcut;
                keymap = [
                  "n"
                  shortcut
                  cmd
                  {}
                ];
                position = "center";
                cursor = 0;
                width = 40;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            };
          in [
            (
              mkButton
              "q"
              "<CMD>qa<CR>"
              " "
              "String"
            )
            (
              mkButton
              "n"
              "<CMD>ene <BAR> startinsert<CR>"
              " New File"
              "String"
            )
            (
              mkButton
              "f"
              "<CMD>lua require('fzf-lua').files()<CR>"
              " Find File"
              "String"
            )
            (
              mkButton
              "g"
              "<CMD>lua require('fzf-lua').live_grep()<CR>"
              " Find Pattern"
              "String"
            )
            (
              mkButton
              "t"
              "<CMD>TodoFzfLua<CR>"
              " Search Todos"
              "String"
            )
          ];
        }
        {
          type = "padding";
          val = 2;
        }
        {
          opts = {
            hl = "GruvboxBlue";
            position = "center";
          };
          type = "text";
          val = "Macbook Airborne";
        }
      ];
    };
  };
}
