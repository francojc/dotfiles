# ~/.config/home/zsh.nix
{ config, pkgs, ... }:
let
  aliasesFile = ./aliases.zsh;
in
{
  programs.zsh = {
    enable = true;

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;

    defaultKeymap = "viins";

    initExtra = ''
      ${builtins.readFile aliasesFile}
    '';

    # Other ZSH plugins
    plugins = [ ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.oh-my-posh = {
    enable = false;
    enableZshIntegration = true;
    useTheme = "avit";
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
