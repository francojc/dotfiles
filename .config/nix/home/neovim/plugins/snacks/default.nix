{pkgs, ...}:
{
  programs.nixvim = {
    plugins.snacks = {
      enable = true;
      package = pkgs.vimPlugins.snacks-nvim;
    };
    imports = [
      ./snacks-bufdelete.nix
      ./snacks-explorer.nix
      ./snacks-git.nix
      ./snacks-notifier.nix
    ];
  };
}
