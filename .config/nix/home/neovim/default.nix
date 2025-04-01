{ inputs, ... }: let
  utils = inputs.nixCats.utils;
in {
  # Do not import nixCats.homeModule here
  config = {
    nixCats = {
      enable = true;
      nixpkgs_version = inputs.nixpkgs;
      addOverlays = /* (import ./overlays inputs) ++ */ [
        (utils.standardPluginOverlay inputs)
      ];
      packageNames = [ "nvix" ];

      luaPath = "${./.}";

      categoryDefinitions.replace = ({ pkgs, settings, categories, extra, name, mkPlugin, ... }@packageDef: {

        lspsAndRuntimeDeps = {
          general = with pkgs; [
            lazygit
          ];
          lua = with pkgs; [
            lua-language-server
            stylua
          ];
          nix = with pkgs; [
            nixd
            alejandra
          ];
        };

        startupPlugins = with pkgs.vimPlugins; {
          general = [
            lze
            lzextras
            plenary-nvim
          ];

          treesitter = [
            nvim-treesitter.withAllGrammars
          ];
        };

        optionalPlugins = {
          lua = with pkgs.vimPlugins; [
            lazydev-nvim
          ];
          general = with pkgs.vimPlugins; [
            nvim-treesitter.withAllGrammars
            lualine-nvim
            lualine-lsp-progress
            gitsigns-nvim
            which-key-nvim
          ];

        };

      }); # Semicolon needed here to separate from next attribute

      packageDefinitions.replace = {
        nvix = {pkgs , ... }: {
          settings = {
            aliases = [ "v" ];
          };
          categories = {
            general = true;
            lua = true;
            nix = true;
          };
          extra = {
            nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
          };
        };
      }; # Semicolon needed here to separate from next attribute (if any) or end the set
    }; # Closes nixCats set
  }; # Closes config set
}
