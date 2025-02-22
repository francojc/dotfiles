 { pkgs, ... }:
 {
   programs.nixvim = {
     plugins.snacks = {
       enable = true;
       package = pkgs.vimPlugins.snacks-nvim;
       settings = {
         bufdelete.enabled = true;
         gitbrowse.enabled = true;
       };
     };
   };
 }
