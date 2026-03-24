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
          vim-fugitive # Git integration (for statusline branch)
          vim-commentary # Commenting
          vim-markdown # Markdown support
          vim-sensible # Sensible defaults
          vim-surround # Surround text objects
          vim-tmux-navigator # Navigate Vim/Tmux panes with C-h/j/k/l
          vim-which-key # Keybindings
          # Theme plugins
          gruvbox # Gruvbox colorscheme
          # kanso-nvim # Kanso colorscheme (Neovim-only, not compatible with Vim)
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
        syntax on                 " Syntax highlighting
        set number                " Show line numbers
        set relativenumber        " Show relative line numbers
        set tabstop=4             " Tab width
        set shiftwidth=4          " Indent width
        set expandtab             " Use spaces instead of tabs
        set smartindent           " Smart auto-indenting
        set hlsearch              " Highlight search results
        set incsearch             " Incremental search
        set ignorecase            " Case-insensitive searching
        set smartcase             " Case-sensitive if uppercase used
        " System clipboard via pbcopy/pbpaste on macOS
        " (Nix Vim is GTK2/X11-compiled; X11 clipboard unavailable on macOS)
        if has('mac') || has('macunix') || system('uname') =~# 'Darwin'
          " Yank to system clipboard
          vnoremap <silent> y y:call system('pbcopy', @")<CR>
          nnoremap <silent> yy yy:call system('pbcopy', @")<CR>
          nnoremap <silent> Y Y:call system('pbcopy', @")<CR>
          " Paste from system clipboard
          nnoremap <silent> p :let @"=system('pbpaste')<CR>p
          nnoremap <silent> P :let @"=system('pbpaste')<CR>P
        else
          set clipboard=unnamedplus
        endif
        set mouse=a               " Enable mouse support
        set autoindent            " Auto-indent
        set hidden                " Hide buffers instead of closing them
        set termguicolors         " True color support
        set undofile              " Save undo history to file
        set undodir=~/.vim/undo   " Save undo history to file
        set undolevels=75         " Maximum number of changes that can be undone
        set noswapfile            " Disable swap files
        set nobackup              " Disable backup files
        set cursorline            " Highlight current line
        colorscheme ${theme.vim.colorscheme}
        set background=${theme.vim.background}

        " STATUSLINE -----------------------------------------------
        set laststatus=2          " Always show statusline
        set showmode              " Show mode in command line (backup)
        set noshowmode            " Hide default mode text (we show it in statusline)

        " Mode mapping function
        function! StatuslineMode()
          let l:mode = mode()
          if l:mode ==# 'n'     | return 'NORMAL'
          elseif l:mode ==# 'i' | return 'INSERT'
          elseif l:mode ==# 'v' | return 'VISUAL'
          elseif l:mode ==# 'V' | return 'V-LINE'
          elseif l:mode ==# "\<C-v>" | return 'V-BLOCK'
          elseif l:mode ==# 'R' | return 'REPLACE'
          elseif l:mode ==# 'c' | return 'COMMAND'
          elseif l:mode ==# 't' | return 'TERMINAL'
          elseif l:mode ==# 's' || l:mode ==# 'S' | return 'SELECT'
          else | return toupper(l:mode)
          endif
        endfunction

        " Git branch (via fugitive)
        function! StatuslineGit()
          if exists('*FugitiveHead')
            let l:branch = FugitiveHead()
            if l:branch != ""
              return '  ' . l:branch . ' '
            endif
          endif
          return ""
        endfunction

        " Modified/readonly indicators
        function! StatuslineModified()
          let l:flags = ""
          if &modified | let l:flags .= " [+]" | endif
          if &readonly | let l:flags .= " []" | endif
          return l:flags
        endfunction

        " Relative filename (to cwd)
        function! StatuslineFilename()
          let l:name = expand('%:~:.')
          if l:name == ""
            return ' [No Name]'
          endif
          return ' ' . l:name
        endfunction

        " Search count
        function! StatuslineSearchCount()
          if v:hlsearch == 0
            return ""
          endif
          try
            let l:result = searchcount({'maxcount': 999, 'timeout': 50})
            if empty(l:result) || l:result.total == 0
              return ""
            endif
            if l:result.incomplete == 1
              return ' ?/? '
            endif
            return ' ' . l:result.current . '/' . l:result.total . ' '
          catch
            return ""
          endtry
        endfunction

        " Statusline highlight groups (linked to existing groups for theme compat)
        function! SetupStatuslineColors()
          hi StatusLineModeNormal  guifg=#282828 guibg=#a89984 gui=bold ctermfg=235 ctermbg=246 cterm=bold
          hi StatusLineModeInsert  guifg=#282828 guibg=#83a598 gui=bold ctermfg=235 ctermbg=109 cterm=bold
          hi StatusLineModeVisual  guifg=#282828 guibg=#fabd2f gui=bold ctermfg=235 ctermbg=214 cterm=bold
          hi StatusLineModeReplace guifg=#282828 guibg=#fb4934 gui=bold ctermfg=235 ctermbg=167 cterm=bold
          hi StatusLineModeCommand guifg=#282828 guibg=#b8bb26 gui=bold ctermfg=235 ctermbg=142 cterm=bold
          hi StatusLineModified   guifg=#fb4934 guibg=#3c3836 gui=bold ctermfg=167 ctermbg=237 cterm=bold
          hi StatusLineGit        guifg=#b8bb26 guibg=#3c3836 gui=NONE ctermfg=142 ctermbg=237
          hi StatusLineFile       guifg=#ebdbb2 guibg=#3c3836 gui=NONE ctermfg=223 ctermbg=237
          hi StatusLineSearch     guifg=#fabd2f guibg=#3c3836 gui=NONE ctermfg=214 ctermbg=237
          hi StatusLineType       guifg=#282828 guibg=#a89984 gui=NONE ctermfg=235 ctermbg=246
          hi StatusLinePos        guifg=#ebdbb2 guibg=#504945 gui=NONE ctermfg=223 ctermbg=239
        endfunction

        augroup StatuslineColors
          autocmd!
          autocmd ColorScheme * call SetupStatuslineColors()
        augroup END
        call SetupStatuslineColors()

        " Dynamic mode highlight
        function! StatuslineModeHighlight()
          let l:mode = mode()
          if l:mode ==# 'i'     | return '%#StatusLineModeInsert#'
          elseif l:mode =~# '[vV\x16]' | return '%#StatusLineModeVisual#'
          elseif l:mode ==# 'R' | return '%#StatusLineModeReplace#'
          elseif l:mode ==# 'c' | return '%#StatusLineModeCommand#'
          else | return '%#StatusLineModeNormal#'
          endif
        endfunction

        " Build statusline
        set statusline=
        set statusline+=%{%StatuslineModeHighlight()%}
        set statusline+=\ %{StatuslineMode()}\ 
        set statusline+=%#StatusLineModified#
        set statusline+=%{StatuslineModified()}
        set statusline+=%#StatusLineGit#
        set statusline+=%{StatuslineGit()}
        set statusline+=%#StatusLineFile#
        set statusline+=%{StatuslineFilename()}
        set statusline+=%#StatusLine#
        set statusline+=%=
        set statusline+=%#StatusLineSearch#
        set statusline+=%{StatuslineSearchCount()}
        set statusline+=%#StatusLineType#
        set statusline+=\ %Y\ 
        set statusline+=%#StatusLinePos#
        set statusline+=\ %3l:%-2c\ 
        set statusline+=%{%StatuslineModeHighlight()%}
        set statusline+=\ %p%%\ 

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

        nnoremap <C-Left> <C-W>h          " Move to window left
        nnoremap <C-Down> <C-W>j          " Move to window below
        nnoremap <C-Up> <C-W>k            " Move to window above
        nnoremap <C-Right> <C-W>l         " Move to window right

        nnoremap <C-=> <C-w>=             " Balance windows
        nnoremap <C-w>o <C-w>o            " Close other windows

        " C-h/j/k/l handled by vim-tmux-navigator

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
