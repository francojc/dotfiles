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

      categoryDefinitions.replace = {
        pkgs,
        settings,
        categories,
        name,
        ...
      } @ packageDef: {
        # General plugins and runtime dependencies
        lspsAndRuntimeDeps = {
          general = with pkgs; [
            lazygit
            fzf
            ripgrep
            fd
            gh
          ];

          lsps = with pkgs; [
            alejandra
            air-formatter
            bash-language-server
            lua-language-server
            marksman
            nix-doc
            nixd
            pyright
            stylua
            shunit2
            yaml-language-server
          ];
        };

        # Plugins that load on startup without packadd
        startupPlugins = {
          general = with pkgs.vimPlugins; [
            alpha-nvim
            blink-cmp
            bufferline-nvim
            codecompanion-nvim
            conform-nvim
            copilot-vim
            friendly-snippets
            fzf-lua
            gitsigns-nvim
            gruvbox
            lualine-lsp-progress
            lualine-nvim
            lze
            lzextras
            mini-nvim
            neo-tree-nvim
            nightfox-nvim
            nvim-lspconfig
            nvim-treesitter.withAllGrammars
            nvim-web-devicons
            obsidian-nvim
            plenary-nvim
            render-markdown-nvim
            todo-comments-nvim
            toggleterm-nvim
            vim-slime
            which-key-nvim
            yazi-nvim
          ];
        };

        # Plugins not loaded on startup
        # Use with packadd and an autocommand to get lazy loading
        optionalPlugins = {
          general = with pkgs.vimPlugins; [
          ];
        };
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
