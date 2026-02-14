{themeName, ...}: let
  themes = {
    arthur = let
      colors = {
        # Background colors
        bg0 = "#1c1c1c";
        bg1 = "#262626";
        bg2 = "#303030";
        bg3 = "#3a3a3a";
        bg4 = "#444444";

        # Foreground colors
        fg0 = "#feffff";
        fg1 = "#e4e4e4";
        fg2 = "#c6c6c6";
        fg3 = "#a8a8a8";

        # Accent colors
        red = "#cd5c5c";
        green = "#86af80";
        yellow = "#e8ae5b";
        blue = "#6495ed";
        purple = "#deb887";
        aqua = "#b0c4de";
        orange = "#ffa500";

        # Bright colors
        bright_red = "#ff6b6b";
        bright_green = "#a0d490";
        bright_yellow = "#ffcc5c";
        bright_blue = "#87ceeb";
        bright_purple = "#f0e68c";
        bright_aqua = "#e0ffff";
        bright_orange = "#ffd700";

        # Special
        cursor = "#ffa500";
        accent = "#ffa500";
      };
    in {
      name = "arthur";
      inherit colors;
      ghostty = {
        theme = "Desert";
        cursor_color = "#ffa500";
      };
      kitty = {
        theme_name = "arthur";
      };
      vim = {
        colorscheme = "desert";
        background = "dark";
      };
      neovim = {
        colorscheme = "arthur";
        colors = {
          bg = "#262626";
          fg = "#e4e4e4";
          yellow = "#e8ae5b";
        };
      };
      ncspot = {
        background = colors.bg0;
        primary = colors.fg0;
        secondary = colors.fg3;
        title = colors.accent;
        playing = colors.accent;
        playing_selected = colors.bright_orange;
        playing_bg = colors.bg0;
        highlight = colors.fg0;
        highlight_bg = colors.bg3;
        error = colors.fg0;
        error_bg = colors.red;
        statusbar = colors.bg0;
        statusbar_progress = colors.accent;
        statusbar_bg = colors.accent;
        cmdline = colors.fg0;
        cmdline_bg = colors.bg0;
        search_match = colors.bright_red;
      };
    };

    autumn = let
      colors = {
        # Background colors
        bg0 = "#2d1b00";
        bg1 = "#402800";
        bg2 = "#533500";
        bg3 = "#664200";
        bg4 = "#794f00";

        # Foreground colors
        fg0 = "#ffd084";
        fg1 = "#e6bb75";
        fg2 = "#cca666";
        fg3 = "#b39157";

        # Accent colors
        red = "#d2691e";
        green = "#8fbc8f";
        yellow = "#daa520";
        blue = "#4682b4";
        purple = "#cd853f";
        aqua = "#5f9ea0";
        orange = "#ff8c00";

        # Bright colors
        bright_red = "#ff6347";
        bright_green = "#98fb98";
        bright_yellow = "#ffd700";
        bright_blue = "#87ceeb";
        bright_purple = "#dda0dd";
        bright_aqua = "#afeeee";
        bright_orange = "#ffa500";

        # Special
        cursor = "#ff8c00";
        accent = "#ff8c00";
      };
    in {
      name = "autumn";
      inherit colors;
      ghostty = {
        theme = "autumn";
        cursor_color = "#ff8c00";
      };
      kitty = {
        theme_name = "autumn";
      };
      vim = {
        colorscheme = "autumn";
        background = "dark";
      };
      neovim = {
        colorscheme = "autumn";
        colors = {
          bg = "#402800";
          fg = "#e6bb75";
          yellow = "#daa520";
        };
      };
      ncspot = {
        background = colors.bg0;
        primary = colors.fg0;
        secondary = colors.fg3;
        title = colors.accent;
        playing = colors.accent;
        playing_selected = colors.bright_orange;
        playing_bg = colors.bg0;
        highlight = colors.fg0;
        highlight_bg = colors.bg3;
        error = colors.fg0;
        error_bg = colors.red;
        statusbar = colors.bg0;
        statusbar_progress = colors.accent;
        statusbar_bg = colors.accent;
        cmdline = colors.fg0;
        cmdline_bg = colors.bg0;
        search_match = colors.bright_red;
      };
    };

    blackmetal = let
      colors = {
        # Background colors
        bg0 = "#000000";
        bg1 = "#121212";
        bg2 = "#222222";
        bg3 = "#333333";
        bg4 = "#444444";

        # Foreground colors
        fg0 = "#c1c1c1";
        fg1 = "#b5b5b5";
        fg2 = "#999999";
        fg3 = "#777777";

        # Accent colors
        red = "#5f8787";
        green = "#dd9999";
        yellow = "#a0a0a0";
        blue = "#888888";
        purple = "#999999";
        aqua = "#aaaaaa";
        orange = "#999999";

        # Bright colors
        bright_red = "#5f8787";
        bright_green = "#dd9999";
        bright_yellow = "#6b4a2e";
        bright_blue = "#3a526b";
        bright_purple = "#543c5f";
        bright_aqua = "#4f6767";
        bright_orange = "#8B5A2B";

        # Special
        cursor = "#8B5A2B";
        accent = "#c1c1c1";
      };
    in {
      name = "blackmetal";
      inherit colors;
      ghostty = {
        theme = "Black Metal (Marduk)";
        cursor_color = "#c1c1c1";
      };
      kitty = {
        theme_name = "blackmetal";
      };
      vim = {
        colorscheme = "zenbones";
        background = "dark";
      };
      neovim = {
        colorscheme = "marduk";
        colors = {
          bg = "#121212";
          fg = "#c1c1c1";
          yellow = "#a0a0a0";
        };
      };
      ncspot = {
        background = colors.bg0;
        primary = colors.fg0;
        secondary = colors.fg3;
        title = colors.accent;
        playing = colors.accent;
        playing_selected = colors.fg0;
        playing_bg = colors.bg0;
        highlight = colors.fg0;
        highlight_bg = colors.bg3;
        error = colors.fg0;
        error_bg = colors.red;
        statusbar = colors.bg0;
        statusbar_progress = colors.accent;
        statusbar_bg = colors.accent;
        cmdline = colors.fg0;
        cmdline_bg = colors.bg0;
        search_match = colors.bright_red;
      };
    };

    gruvbox = let
      colors = {
        # Background colors
        bg0_hard = "#1d2021";
        bg0 = "#282828";
        bg1 = "#3c3836";
        bg2 = "#504945";
        bg3 = "#665c54";
        bg4 = "#7c6f64";

        # Foreground colors
        fg0 = "#fbf1c7";
        fg1 = "#ebdbb2";
        fg2 = "#d5c4a1";
        fg3 = "#bdae93";
        fg4 = "#a89984";

        # Accent colors
        red = "#cc241d";
        green = "#98971a";
        yellow = "#d79921";
        blue = "#458588";
        purple = "#b16286";
        aqua = "#689d6a";
        orange = "#d65d0e";

        # Bright colors
        bright_red = "#fb4934";
        bright_green = "#b8bb26";
        bright_yellow = "#fabd2f";
        bright_blue = "#83a598";
        bright_purple = "#d3869b";
        bright_aqua = "#8ec07c";
        bright_orange = "#fe8019";

        # Gray colors
        gray = "#928374";

        # Special
        cursor = "#fe8019";
        accent = "#fe8019";
      };
    in {
      name = "gruvbox";
      inherit colors;
      ghostty = {
        theme = "GruvboxDarkHard";
        cursor_color = "#fe8019";
      };
      kitty = {
        theme_name = "gruvbox";
      };
      vim = {
        colorscheme = "gruvbox";
        background = "dark";
      };
      neovim = {
        colorscheme = "gruvbox";
        colors = {
          bg = "#3c3836";
          fg = "#ebdbb2";
          yellow = "#fabd2f";
        };
      };
      ncspot = {
        background = colors.bg0;
        primary = colors.fg0;
        secondary = colors.fg3;
        title = colors.accent;
        playing = colors.accent;
        playing_selected = colors.bright_orange;
        playing_bg = colors.bg0;
        highlight = colors.fg0;
        highlight_bg = colors.bg2;
        error = colors.fg0;
        error_bg = colors.red;
        statusbar = colors.bg0;
        statusbar_progress = colors.accent;
        statusbar_bg = colors.accent;
        cmdline = colors.fg0;
        cmdline_bg = colors.bg0;
        search_match = colors.bright_red;
      };
    };

    nightfox = let
      colors = {
        # Background colors
        bg0 = "#192330";
        bg1 = "#212e3f";
        bg2 = "#29394f";
        bg3 = "#39506d";
        bg4 = "#4b6785";

        # Foreground colors
        fg0 = "#cdcecf";
        fg1 = "#aeafb0";
        fg2 = "#9b9ea0";
        fg3 = "#838688";

        # Accent colors
        red = "#c94f6d";
        green = "#81b29a";
        yellow = "#dbc074";
        blue = "#719cd6";
        purple = "#9d79d6";
        aqua = "#63cdcf";
        orange = "#f4a261";

        # Bright colors
        bright_red = "#d16983";
        bright_green = "#8ebaa4";
        bright_yellow = "#e0c989";
        bright_blue = "#86abdc";
        bright_purple = "#baa1e2";
        bright_aqua = "#7ad5d6";
        bright_orange = "#f6a878";

        # Special
        cursor = "#719cd6";
        accent = "#719cd6";
      };
    in {
      name = "nightfox";
      inherit colors;
      ghostty = {
        theme = "nightfox";
        cursor_color = "#719cd6";
      };
      kitty = {
        theme_name = "nightfox";
      };
      vim = {
        colorscheme = "nightfox";
        background = "dark";
      };
      neovim = {
        colorscheme = "nightfox";
        colors = {
          bg = "#212e3f";
          fg = "#cdcecf";
          yellow = "#dbc074";
        };
      };
      ncspot = {
        background = colors.bg0;
        primary = colors.fg0;
        secondary = colors.fg3;
        title = colors.accent;
        playing = colors.accent;
        playing_selected = colors.bright_blue;
        playing_bg = colors.bg0;
        highlight = colors.fg0;
        highlight_bg = colors.bg2;
        error = colors.fg0;
        error_bg = colors.red;
        statusbar = colors.bg0;
        statusbar_progress = colors.accent;
        statusbar_bg = colors.accent;
        cmdline = colors.fg0;
        cmdline_bg = colors.bg0;
        search_match = colors.bright_red;
      };
    };

    onedark = let
      colors = {
        # Background colors
        bg0 = "#282c34";
        bg1 = "#31353f";
        bg2 = "#393f4a";
        bg3 = "#3b3f4c";
        bg_d = "#21252b";

        # Foreground colors
        fg0 = "#abb2bf";
        fg1 = "#abb2bf";
        fg2 = "#848b98";
        fg3 = "#5c6370";

        # Accent colors
        red = "#e86671";
        green = "#98c379";
        yellow = "#e5c07b";
        blue = "#61afef";
        purple = "#c678dd";
        aqua = "#56b6c2";
        cyan = "#56b6c2";
        orange = "#d19a66";

        # Bright colors
        bright_red = "#e86671";
        bright_green = "#98c379";
        bright_yellow = "#e5c07b";
        bright_blue = "#61afef";
        bright_purple = "#c678dd";
        bright_aqua = "#56b6c2";
        bright_orange = "#d19a66";

        # Gray colors
        gray = "#5c6370";
        grey = "#5c6370";
        light_grey = "#848b98";

        # Special
        cursor = "#61afef";
        accent = "#61afef";
      };
    in {
      name = "onedark";
      inherit colors;
      ghostty = {
        theme = "One Half Dark";
        cursor_color = "#61afef";
      };
      kitty = {
        theme_name = "onedark";
      };
      vim = {
        colorscheme = "onedark";
        background = "dark";
      };
      neovim = {
        colorscheme = "onedark";
        colors = {
          bg = "#31353f";
          fg = "#abb2bf";
          yellow = "#e5c07b";
        };
      };
      ncspot = {
        background = colors.bg0;
        primary = colors.fg0;
        secondary = colors.fg3;
        title = colors.accent;
        playing = colors.accent;
        playing_selected = colors.bright_blue;
        playing_bg = colors.bg0;
        highlight = colors.fg0;
        highlight_bg = colors.bg2;
        error = colors.fg0;
        error_bg = colors.red;
        statusbar = colors.bg0;
        statusbar_progress = colors.accent;
        statusbar_bg = colors.accent;
        cmdline = colors.fg0;
        cmdline_bg = colors.bg0;
        search_match = colors.bright_red;
      };
    };

    tokyonight = let
      colors = {
        # Background colors
        bg0 = "#1a1b26";
        bg1 = "#1f2335";
        bg2 = "#24283b";
        bg3 = "#292e42";
        bg4 = "#3b4261";

        # Foreground colors
        fg0 = "#c0caf5";
        fg1 = "#a9b1d6";
        fg2 = "#9aa5ce";
        fg3 = "#828bb8";

        # Accent colors
        red = "#f7768e";
        green = "#9ece6a";
        yellow = "#e0af68";
        blue = "#7aa2f7";
        purple = "#bb9af7";
        aqua = "#7dcfff";
        orange = "#ff9e64";

        # Bright colors
        bright_red = "#ff7a93";
        bright_green = "#b9f27c";
        bright_yellow = "#ff9e64";
        bright_blue = "#7da6ff";
        bright_purple = "#c0a5f9";
        bright_aqua = "#89ddff";
        bright_orange = "#ffc777";

        # Special
        cursor = "#7aa2f7";
        accent = "#7aa2f7";
      };
    in {
      name = "tokyonight";
      inherit colors;
      ghostty = {
        theme = "tokyonight";
        cursor_color = "#7aa2f7";
      };
      kitty = {
        theme_name = "tokyonight";
      };
      vim = {
        colorscheme = "tokyonight";
        background = "dark";
      };
      neovim = {
        colorscheme = "tokyonight-night";
        colors = {
          bg = "#1f2335";
          fg = "#c0caf5";
          yellow = "#e0af68";
        };
      };
      ncspot = {
        background = colors.bg0;
        primary = colors.fg0;
        secondary = colors.fg3;
        title = colors.accent;
        playing = colors.accent;
        playing_selected = colors.bright_blue;
        playing_bg = colors.bg0;
        highlight = colors.fg0;
        highlight_bg = colors.bg2;
        error = colors.fg0;
        error_bg = colors.red;
        statusbar = colors.bg0;
        statusbar_progress = colors.accent;
        statusbar_bg = colors.accent;
        cmdline = colors.fg0;
        cmdline_bg = colors.bg0;
        search_match = colors.bright_red;
      };
    };

    catppuccin = let
      colors = {
        # Background colors
        bg0 = "#11111b";
        bg1 = "#181825";
        bg2 = "#1e1e2e";
        bg3 = "#313244";
        bg4 = "#45475a";

        # Foreground colors
        fg0 = "#cdd6f4";
        fg1 = "#bac2de";
        fg2 = "#a6adc8";
        fg3 = "#9399b2";

        # Accent colors
        red = "#f38ba8";
        green = "#a6e3a1";
        yellow = "#f9e2af";
        blue = "#89b4fa";
        purple = "#cba6f7";
        aqua = "#94e2d5";
        orange = "#fab387";

        # Bright colors
        bright_red = "#f38ba8";
        bright_green = "#a6e3a1";
        bright_yellow = "#f9e2af";
        bright_blue = "#89b4fa";
        bright_purple = "#cba6f7";
        bright_aqua = "#94e2d5";
        bright_orange = "#fab387";

        # Special
        cursor = "#f5e0dc";
        accent = "#89b4fa";
      };
    in {
      name = "catppuccin";
      inherit colors;
      ghostty = {
        theme = "Catppuccin Mocha";
        cursor_color = "#f5e0dc";
      };
      kitty = {
        theme_name = "catppuccin";
      };
      vim = {
        colorscheme = "catppuccin";
        background = "dark";
      };
      neovim = {
        colorscheme = "catppuccin";
        colors = {
          bg = "#1e1e2e";
          fg = "#cdd6f4";
          yellow = "#f9e2af";
        };
      };
      ncspot = {
        background = colors.bg0;
        primary = colors.fg0;
        secondary = colors.fg3;
        title = colors.accent;
        playing = colors.accent;
        playing_selected = colors.bright_blue;
        playing_bg = colors.bg0;
        highlight = colors.fg0;
        highlight_bg = colors.bg3;
        error = colors.fg0;
        error_bg = colors.red;
        statusbar = colors.bg0;
        statusbar_progress = colors.accent;
        statusbar_bg = colors.accent;
        cmdline = colors.fg0;
        cmdline_bg = colors.bg0;
        search_match = colors.bright_red;
      };
    };

    vscode = let
      colors = {
        # Background colors
        bg0 = "#1f1f1f";
        bg1 = "#252526";
        bg2 = "#2d2d30";
        bg3 = "#37373d";
        bg4 = "#404040";

        # Foreground colors
        fg0 = "#d4d4d4";
        fg1 = "#bbbbbb";
        fg2 = "#9d9d9d";
        fg3 = "#808080";

        # Accent colors
        red = "#f44747";
        green = "#6a9955";
        yellow = "#dcdcaa";
        blue = "#569cd6";
        purple = "#c586c0";
        aqua = "#4ec9b0";
        orange = "#ce9178";

        # Bright colors
        bright_red = "#f48771";
        bright_green = "#b5cea8";
        bright_yellow = "#d7ba7d";
        bright_blue = "#9cdcfe";
        bright_purple = "#c586c0";
        bright_aqua = "#4fc1ff";
        bright_orange = "#d16969";

        # Special
        cursor = "#569cd6";
        accent = "#569cd6";
      };
    in {
      name = "vscode";
      inherit colors;
      ghostty = {
        theme = "Dark+";
        cursor_color = "#569cd6";
      };
      kitty = {
        theme_name = "vscode";
      };
      vim = {
        colorscheme = "vscode";
        background = "dark";
      };
      neovim = {
        colorscheme = "vscode";
        colors = {
          bg = "#1f1f1f";
          fg = "#d4d4d4";
          yellow = "#dcdcaa";
        };
      };
      ncspot = {
        background = colors.bg0;
        primary = colors.fg0;
        secondary = colors.fg3;
        title = colors.accent;
        playing = colors.accent;
        playing_selected = colors.bright_blue;
        playing_bg = colors.bg0;
        highlight = colors.fg0;
        highlight_bg = colors.bg2;
        error = colors.fg0;
        error_bg = colors.red;
        statusbar = colors.bg0;
        statusbar_progress = colors.accent;
        statusbar_bg = colors.accent;
        cmdline = colors.fg0;
        cmdline_bg = colors.bg0;
        search_match = colors.bright_red;
      };
    };

    vague = let
      colors = {
        # Background colors
        bg0 = "#18191a";
        bg1 = "#1c1d1e";
        bg2 = "#2a2d2e";
        bg3 = "#3c4142";
        bg4 = "#4e5556";

        # Foreground colors
        fg0 = "#cdcdcd";
        fg1 = "#b9b9b9";
        fg2 = "#a5a5a5";
        fg3 = "#919191";

        # Accent colors
        red = "#d2788c";
        green = "#a6b89d";
        yellow = "#e6c792";
        blue = "#8db4d4";
        purple = "#b4a4d4";
        aqua = "#87ceeb";
        orange = "#d99669";

        # Bright colors
        bright_red = "#e68aa1";
        bright_green = "#b7c7a8";
        bright_yellow = "#f0d3a7";
        bright_blue = "#a2c4e0";
        bright_purple = "#c7b7e0";
        bright_aqua = "#9dd9f3";
        bright_orange = "#e6a97e";

        # Special
        cursor = "#8db4d4";
        accent = "#8db4d4";
      };
    in {
      name = "vague";
      inherit colors;
      ghostty = {
        theme = "vague";
        cursor_color = "#8db4d4";
      };
      kitty = {
        theme_name = "vague";
      };
      vim = {
        colorscheme = "vague";
        background = "dark";
      };
      neovim = {
        colorscheme = "vague";
        colors = {
          bg = "#1c1d1e";
          fg = "#b9b9b9";
          yellow = "#e6c792";
        };
      };
      ncspot = {
        background = colors.bg0;
        primary = colors.fg0;
        secondary = colors.fg3;
        title = colors.accent;
        playing = colors.accent;
        playing_selected = colors.bright_blue;
        playing_bg = colors.bg0;
        highlight = colors.fg0;
        highlight_bg = colors.bg2;
        error = colors.fg0;
        error_bg = colors.red;
        statusbar = colors.bg0;
        statusbar_progress = colors.accent;
        statusbar_bg = colors.accent;
        cmdline = colors.fg0;
        cmdline_bg = colors.bg0;
        search_match = colors.bright_red;
      };
    };

    ayu = let
      colors = {
        # Background colors
        bg0 = "#212733";
        bg1 = "#272D38";
        bg2 = "#2D3640";
        bg3 = "#343F4C";
        bg4 = "#3D4751";

        # Foreground colors
        fg0 = "#D9D7CE";
        fg1 = "#D9D7CE";
        fg2 = "#607080";
        fg3 = "#5C6773";

        # Accent colors
        red = "#F07178";
        green = "#BBE67E";
        yellow = "#FFD57F";
        blue = "#80D4FF";
        purple = "#D4BFFF";
        aqua = "#5CCFE6";
        orange = "#FFAE57";

        # Bright colors
        bright_red = "#F07178";
        bright_green = "#BBE67E";
        bright_yellow = "#FFD57F";
        bright_blue = "#80D4FF";
        bright_purple = "#D4BFFF";
        bright_aqua = "#5CCFE6";
        bright_orange = "#FFAE57";

        # Special
        cursor = "#FFCC66";
        accent = "#FFCC66";
      };
    in {
      name = "ayu";
      inherit colors;
      ghostty = {
        theme = "Ayu Mirage";
        cursor_color = "#FFCC66";
      };
      kitty = {
        theme_name = "Ayu Mirage";
      };
      vim = {
        colorscheme = "ayu";
        background = "dark";
      };
      neovim = {
        colorscheme = "ayu";
        colors = {
          bg = "#272D38";
          fg = "#D9D7CE";
          yellow = "#FFD57F";
        };
      };
      ncspot = {
        background = colors.bg0;
        primary = colors.fg0;
        secondary = colors.fg3;
        title = colors.accent;
        playing = colors.accent;
        playing_selected = colors.bright_orange;
        playing_bg = colors.bg0;
        highlight = colors.fg0;
        highlight_bg = colors.bg2;
        error = colors.fg0;
        error_bg = colors.red;
        statusbar = colors.bg0;
        statusbar_progress = colors.accent;
        statusbar_bg = colors.accent;
        cmdline = colors.fg0;
        cmdline_bg = colors.bg0;
        search_match = colors.bright_red;
      };
    };
  };

  # Current active theme - set by host configuration
  currentTheme = themes.${themeName};
in {
  # Export theme data for other modules
  _module.args.theme = currentTheme;

  # Generate Neovim theme config file
  xdg.configFile."nvim/lua/theme-config.lua".text = ''
    return {
      colorscheme = "${currentTheme.neovim.colorscheme}",
      colors = {
        bg = "${currentTheme.neovim.colors.bg}",
        fg = "${currentTheme.neovim.colors.fg}",
        yellow = "${currentTheme.neovim.colors.yellow}",
      }
    }
  '';

  # Generate theme config for nvim-nix (stable 0.11.x)
  xdg.configFile."nvim-nix/lua/theme-config.lua".text = ''
    return {
      colorscheme = "${currentTheme.neovim.colorscheme}",
      colors = {
        bg = "${currentTheme.neovim.colors.bg}",
        fg = "${currentTheme.neovim.colors.fg}",
        yellow = "${currentTheme.neovim.colors.yellow}",
      }
    }
  '';
}
