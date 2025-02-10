{pkgs, ...}:
{
  programs.nixvim = {
  plugins.snacks = {
    enable = true;
    package = pkgs.vimPlugins.snacks-nvim;
    settings = {
        picker = {
          enable = true;
          layout = "vertical";
        };
        explorer.enable = true;
      };
    };
  };
}
