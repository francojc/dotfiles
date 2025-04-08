{inputs, ...}: let
  utils = inputs.nixCats.utils;
in {
  config = {
    nixCats = {
      enable = true;
      nixpkgs_version = inputs.nixpkgs;
      addOverlays =
        /*
        (import ./overlays inputs) ++
        */
        [
          (utils.standardPluginOverlay inputs)
        ];
      packageNames = ["nvix"];

      luaPath = "${./.}";

      categoryDefinitions.replace = {pkgs, ...} @ packageDef: {
        lspsAndRuntimeDeps = {
          general = with pkgs; [
            fd
            fzf
            gh
            imagemagick
            lazygit
            nodejs-slim_23
            ripgrep
          ];

          lsps = with pkgs; [
            alejandra
            air-formatter
            bash-language-server
            copilot-language-server
            lua-language-server
            mdformat
            nix-doc
            nixd
            nodePackages.prettier
            pyright
            stylua
            shunit2
            shfmt
            yaml-language-server
          ];
        };

        # Plugins that load on startup without packadd
        startupPlugins = {
          general = with pkgs.vimPlugins; [
            aerial-nvim
            alpha-nvim
            auto-session
            blink-cmp
            bufferline-nvim
            codecompanion-nvim
            conform-nvim
            copilot-vim
            fidget-nvim
            flash-nvim
            friendly-snippets
            fzf-lua
            gitsigns-nvim
            gruvbox-nvim
            image-nvim
            img-clip-nvim
            lazygit-nvim
            lualine-lsp-progress
            lualine-nvim
            mini-nvim
            nightfox-nvim
            nvim-colorizer-lua
            nvim-lspconfig
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
            nvim-web-devicons
            obsidian-nvim
            oil-nvim
            plenary-nvim
            quarto-nvim
            render-markdown-nvim
            todo-comments-nvim
            toggleterm-nvim
            tokyonight-nvim
            vim-slime
            which-key-nvim
            yazi-nvim
          ];
        };

        # Plugins not loaded on startup
        # Use with packadd and an autocommand to get lazy loading
        # optionalPlugins = {
        #   general = with pkgs.vimPlugins; [
        #   ];
        # };
      };

      packageDefinitions.replace = {
        nvix = {pkgs, ...}: {
          settings = {
            aliases = ["v" "nvim"];
          };
          categories = {
            general = true;
            lsps = true;
          };
          extra = {
            nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
          };
        };
      };
    };
  };
}
