{ inputs, ... }: 
let
  utils = inputs.nixCats.utils;
in {
  config = {
    nixCats = {
      enable = true;
      nixpkgs_version = inputs.nixpkgs;
      addOverlays = /* (import ./overlays inputs) ++ */ [
        (utils.standardPluginOverlay inputs)
      ];
      packageNames = [ "nvix" ];

      luaPath = "${./.}";

      categoryDefinitions.replace = ({ pkgs, settings, categories, name, ... }@packageDef: {

        lspsAndRuntimeDeps = {
          general = with pkgs; [
            lazygit
            fzf
            ripgrep
            fd
            gh
          ];

          lsps = with pkgs; [
            bash-language-server
            lua-language-server
            nil
            nix-doc
            pyright
            yaml-language-server
          ];

        };
        
        startupPlugins = with pkgs.vimPlugins; {

          general = [
            conform-nvim
            fidget-nvim
            fzf-lua
            gitsigns-nvim
            lze
            lzextras
            neo-tree-nvim
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
            nvim-web-devicons
            plenary-nvim
            toggleterm-nvim
            which-key-nvim
          ];

          colorschemes = [
            gruvbox
            rose-pine
            nightfox
            onedark
            tokyonight

          ];

          completions = [
            blink-cmp              
          ];
          
          ui = [
            alpha-nvim
            bufferline-nvim
            nvim-autopairs
            nvim-colorizer-lua
            nvim-notify
            nvim-tree-nvim
          ];

          ai = [
            copilot-lua
            CopilotChat-nvim
            codecompanion-nvim
          ];

        };

        optionalPlugins = {
          lua = with pkgs.vimPlugins; [
            lazydev-nvim
          ];

          general = with pkgs.vimPlugins; [
            lualine-nvim
            lualine-lsp-progress
            gitsigns-nvim
            which-key-nvim
          ];

        };

      }); 

      packageDefinitions.replace = {
        nvix = {pkgs , ... }: {
          settings = {
            aliases = [ "v" "nvim" ];
          };
          categories = {
            general = true;
            completions = true;
            colorschemes = true;
            ui = true;
            ai = true;
          };
          extra = {
            nixdExtras.nixpkgs = ''import ${pkgs.path} {}'';
          };
        };
      }; 
    }; 
  }; 
}
