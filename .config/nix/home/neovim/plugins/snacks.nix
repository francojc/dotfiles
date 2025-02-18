 { pkgs, ... }:
 {
   programs.nixvim = {
     plugins.snacks = {
       enable = true;
       package = pkgs.vimPlugins.snacks-nvim;

       # Consolidate all settings into one place
       settings = {
         bufdelete.enable = true;
         explorer.enable = true;
         git.enable = true;
         gitbrowser.enable = true;
         image.enable = true;
         notifier.enable = true;
         picker = {
           enable = true;
           layout = "vertical";
         };
       };
     };
   };
 }
