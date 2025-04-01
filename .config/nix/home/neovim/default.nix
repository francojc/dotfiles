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
            nix-doc
            nixd
            pyright
            stylua
            yaml-language-server
          ];
        };

        # Plugins that load on startup without packadd
        startupPlugins = {
          general = with pkgs.vimPlugins; [
            codecompanion-nvim
            copilot-vim
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
            nvim-web-devicons
            plenary-nvim
            toggleterm-nvim
            which-key-nvim
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
          };
          extra = {
            nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
          };
        };
      };
    };
  };
}
