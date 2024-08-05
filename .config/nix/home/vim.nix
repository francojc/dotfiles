# ~/.config/home/vim.nix
{ config, pkgs, ... }:
{
  # FIX: xquartz opens a window when running vim, do not want
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-airline
      nerdtree
    ];
    settings = {
      background = "dark";
      copyindent = true;
      expandtab = true;
      ignorecase = true;
      history = 1000;
      mouse = "a";
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      smartcase = true;
    };
    extraConfig = ''
      " mappings
      let mapleader = " "
      map <leader>n :NERDTree<cr>
      inoremap jj <esc>
      " general
      set nocompatible
      set nobackup
      set nowritebackup
      set noswapfile
      set clipboard = "unnamedplus"
    '';
  };
}
