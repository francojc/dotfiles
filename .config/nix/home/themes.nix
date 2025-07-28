{
  lib,
  themeName,
  ...
}: let
  themes = {
    gruvbox = {
      name = "gruvbox";
      wallpaper_dir = "gruvbox";
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
      ghostty = {
        theme = "GruvboxDarkHard";
        cursor_color = "#fe8019";
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
    };

    nightfox = {
      name = "nightfox";
      wallpaper_dir = "nightfox";
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
      ghostty = {
        theme = "nightfox";
        cursor_color = "#719cd6";
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
    };

    arthur = {
      name = "arthur";
      wallpaper_dir = "arthur";
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

        # Special
        cursor = "#ffa500";
        accent = "#ffa500";
      };
      ghostty = {
        theme = "Arthur";
        cursor_color = "#ffa500";
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
    };

    onedark = {
      name = "onedark";
      wallpaper_dir = "onedark";
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
      ghostty = {
        theme = "OneHalfDark";
        cursor_color = "#61afef";
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
}
