{pkgs, ...}: {
  programs.nixvim = {
    plugins.snacks = {
      enable = false;
      package = pkgs.vimPlugins.snacks-nvim;
      settings = {
        bufdelete.enabled = true;
        gitbrowse.enabled = true;
      };
    };
  };
}
