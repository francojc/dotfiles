 { pkgs, ... }:
 {
   programs.nixvim = {
     plugins.snacks = {
       enable = true;
       # package = pkgs.vimPlugins.snacks-nvim;
       settings = {
         bufdelete.enabled = true;
         explorer = {
           enabled = true;
           replace_netrw = true;
         };
         git.enabled = true;
         gitbrowser.enabled = true;
         image.enabled = true;
         input.enabled = true;
         notifier.enabled = true;
         picker = {
           enabled = true;
           layout = "vertical";
         };
       };
     };
   };
 }
