{ config, pkgs, lib, ... }:

let
  autoCmd = import ./autocommands.nix;
  keymaps = import ./keymaps.nix;
  opts = import ./opts.nix;
  pluginConfigs = map import [
    # Colorscheme
    ./plugins/colorscheme/colorscheme.nix
    ./plugins/colorscheme/colorizer.nix
    # Completion
    ./plugins/completion/cmp.nix
    ./plugins/completion/lspkind.nix
    # Git
    ./plugins/git/gitsigns.nix
    ./plugins/git/lazygit.nix
    # LSP
    ./plugins/lsp/conform.nix
    ./plugins/lsp/fidget.nix
    ./plugins/lsp/hlchunk.nix
    ./plugins/lsp/lsp.nix
    ./plugins/lsp/lspsaga.nix
    ./plugins/lsp/none-ls.nix
    ./plugins/lsp/trouble.nix
    # Snippets
    ./plugins/snippets/luasnip.nix
    # Statusline
    ./plugins/statusline/lualine.nix
    # Treesitter
    ./plugins/treesitter/treesitter-context.nix
    ./plugins/treesitter/treesitter.nix
    # UI
    ./plugins/ui/alpha.nix
    ./plugins/ui/bufferline.nix
    # ./plugins/ui/headlines.nix
    ./plugins/ui/nvim-notify.nix
    ./plugins/ui/nvim-tree.nix
    ./plugins/ui/precognition.nix
    ./plugins/ui/telescope.nix
    # Utils
    ./plugins/utils/airline.nix
    ./plugins/utils/codecompanion.nix
    ./plugins/utils/comment.nix
    ./plugins/utils/copilot-chat.nix
    ./plugins/utils/copilot.nix
    ./plugins/utils/flash.nix
    ./plugins/utils/harpoon.nix
    ./plugins/utils/illuminate.nix
    ./plugins/utils/markdown.nix
    # ./plugins/utils/markview.nix
    ./plugins/utils/mini.nix
    ./plugins/utils/nvim-autopairs.nix
    ./plugins/utils/obsidian.nix
    ./plugins/utils/oil.nix
    ./plugins/utils/slime.nix
    ./plugins/utils/todo-comments.nix
    ./plugins/utils/ufo.nix
    ./plugins/utils/undotree.nix
    ./plugins/utils/whichkey.nix
    ./plugins/utils/yaml-companion.nix
  ];
in
{
  programs.nixvim = lib.mkMerge ([{
    enable = true;
    globals.mapleader = " ";
    autoGroups = {
      "personal" = {
        clear = true;
      };
    };
    inherit autoCmd;
    inherit keymaps;
    inherit opts;
  }] ++ pluginConfigs);
}
