{
  programs = {
    # Enable some useful shells
    vim = {
      enable = true;
      extraconfig = ''
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

        " Switch between splits
        map <C-j> <C-W>j
        map <C-k> <C-W>k
        map <C-h> <C-W>h
        map <C-l> <C-W>l

        " Map jj to <Esc>
        inoremap jj <Esc>

        colorscheme quiet       " Simple colorscheme
      '';
    };
  };
}
