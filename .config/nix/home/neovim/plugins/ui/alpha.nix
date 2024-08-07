{
  plugins.alpha =
    let
      nixFlake = [
        "                                                     "
        " ███    ██ ███████  ██████  ██    ██ ██ ███    ███   "
        " ████   ██ ██      ██    ██ ██    ██ ██ ████  ████   "
        " ██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██   "
        " ██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██   "
        " ██   ████ ███████  ██████    ████   ██ ██      ██   "
        "                                                     "
      ];
    in
    {
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
          val =
            let
              mkButton = shortcut: cmd: val: hl: {
                type = "button";
                inherit val;
                opts = {
                  inherit hl shortcut;
                  keymap = [
                    "n"
                    shortcut
                    cmd
                    { }
                  ];
                  position = "center";
                  cursor = 0;
                  width = 40;
                  align_shortcut = "right";
                  hl_shortcut = "Keyword";
                };
              };
            in
            [
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
                  "<CMD>Telescope find_files<CR>"
                  " Find File"
                  "String"
              )
              (
                mkButton
                  "p"
                  "<CMD>Telescope live_grep<CR>"
                  " Find Pattern"
                  "String"
              )
              (
                mkButton
                  "b"
                  "<CMD>Telescope file_browser<CR>"
                  " File Browser"
                  "String"
              )
              (
                mkButton
                  "t"
                  "<CMD>TodoTelescope<CR>"
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
}
