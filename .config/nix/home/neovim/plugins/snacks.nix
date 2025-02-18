 { pkgs, ... }:
 {
   programs.nixvim = {
     plugins.snacks = {
       enable = true;
       package = pkgs.vimPlugins.snacks-nvim;

       # Consolidate all settings into one place
       settings = {
         bufdelete = {
           enabled = true;
         };
         explorer = {
           enabled = true;
         };
         git = {
           enabled = true;
         };
         gitbrowser = {
           enabled = true;
         };
         notifier = {
           enabled = true;
           style = "minimal";
           timeout = 3000;
         };
         picker = {
           enabled = true;
           sources = {
             explorer = {};
           };
           win = {
             input = {
               keys = {};
             };
           };
         };
       };
     };
   };
 }
