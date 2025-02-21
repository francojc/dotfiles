 { pkgs, ... }:
 {
   programs.nixvim = {
     plugins.snacks = {
       enable = true;
       package = pkgs.vimPlugins.snacks-nvim;
       settings = {
         bufdelete.enabled = true;
         gitbrowse.enabled = true;
         notifier.enabled = true;
         scratch.enabled = true;
         toggle.enabled = true;
         words.enabled = true;
       };
     };
   };
 }
