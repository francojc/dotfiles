{pkgs, ...}:
{
  programs.nixvim = {
    plugins.snacks = {
      enable = true;
      package = pkgs.vimPlugins.snacks-nvim;
    };
    imports = [
      ./snacks-git.nix
      ./snacks-notifier.nix
    ];
  };
}
