{
  lib,
  themeName,
  ...
}: let
  themes = {
    arthur = {
      name = "arthur";
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
      ghostty = {
        theme = "Desert";
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

    autumn = {
      name = "autumn";
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
      ghostty = {
        theme = "autumn";
        cursor_color = "#ff8c00";
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
    };

    blackmetal = {
      name = "blackmetal";
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
        bright_yellow = "#a0a0a0";
        bright_blue = "#888888";
        bright_purple = "#999999";
        bright_aqua = "#aaaaaa";
        bright_orange = "#999999";

        # Special
        cursor = "#c1c1c1";
        accent = "#c1c1c1";
      };
      ghostty = {
        theme = "blackmetal";
        cursor_color = "#c1c1c1";
      };
      vim = {
        colorscheme = "blackmetal";
        background = "dark";
      };
      neovim = {
        colorscheme = "blackmetal";
        colors = {
          bg = "#121212";
          fg = "#c1c1c1";
          yellow = "#a0a0a0";
        };
      };
    };

    gruvbox = {
      name = "gruvbox";
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
        theme = "Gruvbox Dark Hard";
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

    onedark = {
      name = "onedark";
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

    vague = {
      name = "vague";
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
      ghostty = {
        theme = "vague";
        cursor_color = "#8db4d4";
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
