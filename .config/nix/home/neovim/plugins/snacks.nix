 { pkgs, ... }:
 {
   programs.nixvim = {
     plugins.snacks = {
       enable = true;
       package = pkgs.vimPlugins.snacks-nvim;
       settings = {
         bufdelete.enabled = true;
         git.enabled = true;
         gitbrowse.enabled = true;
         notifier.enabled = true;
         toggle.enabled = true;
       };
     };
   };
 }
