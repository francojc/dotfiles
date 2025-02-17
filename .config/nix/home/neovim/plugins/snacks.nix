{pkgs, ...}:
{
  programs.nixvim = {
  plugins.snacks = {
    enable = true;
    package = pkgs.vimPlugins.snacks-nvim;
    settings = {
      git.enabled = true;
      gitbrowse.enabled = true;
      };
    };
  };
}
