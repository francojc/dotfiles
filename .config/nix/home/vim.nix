{
  pkgs,
  theme,
  ...
}: {
  programs = {
    # Enable some useful shells
    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins;
        [
          # Add your favorite plugins here
          copilot-vim # Copilot
          fzf-vim # FZF
          vim-airline # Status bar
          vim-commentary # Commenting
          vim-markdown # Markdown support
          vim-sensible # Sensible defaults
          vim-surround # Surround text objects
          vim-which-key # Keybindings
          # Theme plugins
          gruvbox # Gruvbox colorscheme
          zenbones-nvim # Zenbones colorscheme
        ]
        ++ (
          if theme.vim.colorscheme == "nightfox"
          then [
            pkgs.vimPlugins.nightfox-nvim
          ]
          else []
        );
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
        set clipboard=unnamedplus " Use system clipboard
        syntax on               " Syntax highlighting
        set mouse=a             " Enable mouse support
        set clipboard=unnamed   " Use system clipboard
        set autoindent          " Auto-indent
        set hidden              " Hide buffers instead of closing them
        set termguicolors       " True color support
        set undofile            " Save undo history to file
        set undodir=~/.vim/undo " Save undo history to file
        set undolevels=75       " Maximum number of changes that can be undone
        set noswapfile          " Disable swap files
        set nobackup            " Disable backup files
        set cursorline          " Highlight current line
        colorscheme ${theme.vim.colorscheme}
        set background=${theme.vim.background}

        " KEYMAPS --------------------------------------------------
        let mapleader = ' '     " Leader key is <Space>

        " General
        nnoremap <leader>h :set hlsearch!<cr> " Toggle search highlighting
        nnoremap <leader>fe :Ex<cr>           " Open file explorer

        inoremap jj <Esc>                     " jj to escape insert mode

        nnoremap <leader>w :w<cr>            " Save file
        nnoremap <leader>q :q<cr>            " Close file
        nnoremap <leader>Q :q!<cr>           " Close file without saving

        " FZF
        nnoremap <leader>ff :FZF<cr>
        nnoremap <leader>fg :GFiles<cr>
        nnoremap <leader>fb :Buffers<cr>
        nnoremap <leader>fl :Lines<cr>
        nnoremap <leader>fr :Rg<cr>

        " Window management
        nnoremap <silent> <leader>s :split<cr> " Split window
        nnoremap <silent> <leader>v :vsplit<cr> " Split window vertically

        nnoremap <C-Left> <C-W>h           " Move to window left
        nnoremap <C-Down> <C-W>j           " Move to window below
        nnoremap <C-Up> <C-W>k             " Move to window above
        nnoremap <C-Right> <C-W>l          " Move to window right

        nnoremap <C-=> <C-w>=              " Balance windows
        nnoremap <C-w>o <C-w>o             " Close other windows

        map <C-j> <C-W>j             " Move to window below
        map <C-k> <C-W>k             " Move to window above
        map <C-h> <C-W>h             " Move to window left
        map <C-l> <C-W>l             " Move to window right

        " Buffer management
        nnoremap <leader>bd :bd<cr>       " Close buffer
        nnoremap <leader>bn :bn<cr>       " Next buffer
        nnoremap <leader>bp :bp<cr>       " Previous buffer

        " Which Key
        " Open which key menu
        nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<cr>
        vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<cr>

        let g:which_key_map = {
            \ 'f': 'File',
            \ 'b': 'Buffer',
            \ 'g': 'Git',
            \ 'w': 'Window',
            \ 's': 'Search',
            \ 't': 'Tags',
            \ 'p': 'Project',
            \ 'l': 'LSP',
            \ 'c': 'Code',
            \ 'h': 'Help',
            \ 'q': 'Quit',
            \ 'a': 'Actions',
            \ 'r': 'Replace',
            \ 'o': 'Open',
            \ 'm': 'Make',
            \ 'n': 'Notes',
            \ 'e': 'Errors',
            \ 'd': 'Debug',
            \ 'i': 'Info',
            \ 'j': 'Jump',
            \ 'k': 'Keybindings',
            \ 'u': 'User',
            \ 'v': 'Vim',
            \ 'x': 'Extra',
            \ 'y': 'Yank',
            \ 'z': 'Zen',
            \ }

        " AUTOCOMMANDS ---------------------------------------------
        " Highlight on Yank
        au TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=200}

      '';
    };
  };
}
