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
          # Plugins: 
          llama-vim # FIM completion from llama.cpp (self-hosted)
          fzf-vim # FZF
          vim-fugitive # Git integration (for statusline branch)
          vim-commentary # Commenting
          vim-markdown # Markdown support
          vim-surround # Surround text objects
          vim-tmux-navigator # Navigate Vim/Tmux panes with C-h/j/k/l
          vim-which-key # Keybindings
        ];
      extraConfig = ''
        " LLAMA.VIM -----------------------------------------------
        let g:llama_config = {
            \ 'enable_at_startup': 1,
            \ 'auto_fim': 1,
            \ 'max_line_suffix': 8,
            \ 'endpoint_fim': 'http://100.101.38.4:8080/infill',
            \ 'api_key': 'de7df50cff8b8ed12426b5d2af443c6644a356f7359ca6ba5d221b23b7339ec1',
            \ 'model_fim': "",
            \ 'n_prefix': 512,
            \ 'n_suffix': 64,
            \ 'n_predict': 128,
            \ 'stop_strings': [],
            \ 't_max_prompt_ms': 1000,
            \ 't_max_predict_ms': 1000,
            \ 'max_cache_keys': 250,
            \ 'ring_n_chunks': 16,
            \ 'ring_chunk_size': 32,
            \ 'ring_scope': 1024,
            \ 'ring_update_ms': 1000,
            \ 'keymap_fim_trigger': '<C-N>',
            \ 'keymap_fim_accept_full': '<Tab>',
            \ 'keymap_fim_accept_line': '<C-F>',
            \ 'keymap_fim_accept_word': '<C-D>',
            \ 'show_info': 2,
            \ }

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
        colorscheme retrobox 
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
        set statusline+=\ %{StatuslineMode()}
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
        set statusline+=\ %Y
        set statusline+=%#StatusLinePos#
        set statusline+=\ %3l:%-2c
        set statusline+=%{%StatuslineModeHighlight()%}
        set statusline+=\ %p%%

        " KEYMAPS --------------------------------------------------
        let mapleader = ' '     " Leader key is <Space>

        " General
        nnoremap <leader>h :set hlsearch!<cr>
        nnoremap <leader>fe :Ex<cr>

        inoremap jj <Esc>

        nnoremap <leader>w :w<cr>
        nnoremap <leader>q :q<cr>
        nnoremap <leader>Q :q!<cr>

        " FZF
        nnoremap <leader>ff :FZF<cr>
        nnoremap <leader>fg :GFiles<cr>
        nnoremap <leader>fb :Buffers<cr>
        nnoremap <leader>fl :Lines<cr>
        nnoremap <leader>fr :Rg<cr>

        " Window management
        nnoremap <silent> <leader>s :split<cr>
        nnoremap <silent> <leader>v :vsplit<cr>

        nnoremap <C-Left> <C-W>h
        nnoremap <C-Down> <C-W>j
        nnoremap <C-Up> <C-W>k
        nnoremap <C-Right> <C-W>l

        nnoremap <C-=> <C-w>=
        nnoremap <C-w>o <C-w>o

        " C-h/j/k/l handled by vim-tmux-navigator

        " Buffer management
        nnoremap <leader>bd :bd<cr>
        nnoremap <leader>bn :bn<cr>
        nnoremap <leader>bp :bp<cr>

        " WHICH KEY ------------------------------------------------
        " Appearance
        let g:which_key_sep = '  '
        let g:which_key_sort_last = 1
        let g:which_key_use_floating_win = 0
        let g:which_key_flatten = 1
        let g:which_key_display_names = {
            \ '<CR>': '↵',
            \ '<TAB>': '⇥',
            \ '<BS>': '⌫',
            \ '<ESC>': '⎋',
            \ ' ': 'SPC',
            \ }

        " Highlight groups (defined after colorscheme loads)
        function! SetupWhichKeyColors()
          hi WhichKey          guifg=#fabd2f gui=bold
          hi WhichKeySeperator guifg=#504945 gui=NONE
          hi WhichKeyGroup     guifg=#83a598 gui=bold
          hi WhichKeyDesc      guifg=#ebdbb2 gui=NONE
          hi WhichKeyFloating  guibg=#1d2021
        endfunction
        augroup WhichKeyColors
          autocmd!
          autocmd ColorScheme * call SetupWhichKeyColors()
        augroup END
        call SetupWhichKeyColors()

        " Map definition — register BEFORE binding the keys
        let g:which_key_map = {}

        " Top-level bindings with clean descriptions
        let g:which_key_map['h'] = ['set hlsearch!',   '⟳ toggle search highlight']
        let g:which_key_map['w'] = ['w',               ' save file']
        let g:which_key_map['q'] = ['q',               ' quit']
        let g:which_key_map['Q'] = ['q!',              ' force quit']
        let g:which_key_map['s'] = ['split',           ' split horizontal']
        let g:which_key_map['v'] = ['vsplit',          ' split vertical']

        " File group
        let g:which_key_map['f'] = {
            \ 'name': ' +file',
            \ 'f': ['FZF',     'find files'],
            \ 'g': ['GFiles',  'git files'],
            \ 'b': ['Buffers', 'open buffers'],
            \ 'l': ['Lines',   'lines in buffer'],
            \ 'r': ['Rg',      'ripgrep search'],
            \ 'e': ['Ex',      'file explorer'],
            \ }

        " Buffer group
        let g:which_key_map['b'] = {
            \ 'name': ' +buffer',
            \ 'd': ['bd', 'delete buffer'],
            \ 'n': ['bn', 'next buffer'],
            \ 'p': ['bp', 'prev buffer'],
            \ }

        " Register the map so which-key uses descriptions instead of raw cmds
        call which_key#register('<Space>', "g:which_key_map")

        " Open which-key menu
        nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<cr>
        vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<cr>

        " AUTOCOMMANDS ---------------------------------------------
        " Highlight on Yank
        au TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=200}

      '';
    };
  };
}
