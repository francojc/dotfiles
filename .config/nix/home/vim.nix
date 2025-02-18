{pkgs, ...}: {
  programs = {
    # Enable some useful shells
    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        # Add your favorite plugins here
        copilot-vim # Copilot
        mini-indentscope # Indentation scope
        mini-files # File explorer
      ];
      extraConfig = ''
        " GENERAL --------------------------------------------------
        set number              " Show line numbers
        set relativenumber      " Show relative line numbers
        set tabstop=4           " Tab width
        set shiftwidth=4        " Indent width
        set expandtab           " Use spaces instead of tabs
        set smartindent         " Smart auto-indenting
        set hlsearch            " Highlight search results
        set incsearch           " Incremental search
        set ignorecase          " Case-insensitive searching
        set smartcase           " Case-sensitive if uppercase used

        syntax on               " Syntax highlighting
        set mouse=a             " Enable mouse support

        " KEYMAPS --------------------------------------------------
        " Switch between splits
        map <C-j> <C-W>j
        map <C-k> <C-W>k
        map <C-h> <C-W>h
        map <C-l> <C-W>l

        " Map jj to <Esc>
        inoremap jj <Esc>

        colorscheme quiet       " Simple colorscheme

        " AUTOCOMMANDS ---------------------------------------------
        " Highlight on Yank
        au TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=200}

      '';
    };
  };
}
