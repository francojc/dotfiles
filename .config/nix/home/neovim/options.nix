{
  config,
  username,
  ...
}: {
  programs.nixvim = {
    globals = {
      loaded_ruby_provider = 0;
      loaded_perl_provider = 0;
    };
    extraConfigLua = ''
      vim.b.slime_cell_delimiter = '```';

      -- Neovim 0.11: Configure diagnostics display.
      -- Virtual text is now opt-in. You can use:
      -- virtual_text = true, -- Enable virtual text globally (like < 0.11)
      -- virtual_text = { current_line = true }, -- Enable only for current line
      -- virtual_lines = true, -- Enable the new virtual lines feature
      -- Or combine them, e.g., virtual_text = true, virtual_lines = { current_line = true }
      vim.diagnostic.config({
        virtual_text = { current_line = true }, -- Example: virtual text on current line only
        -- virtual_lines = true, -- Uncomment to enable virtual lines instead/additionally
      })
    '';
    extraConfigVim = ''
      highlight WinSeparator guifg=#FABD2F
    '';
    opts = {
      # Enable relative line numbers
      number = true;
      relativenumber = true;
      clipboard = "unnamedplus";

      completeopt = ["menuone" "noselect" "noinsert"];
      sessionoptions = "blank,buffers,curdir,folds,tabpages,winsize,localoptions,terminal";

      # Spell
      spell = false;
      spelllang = "en_us";
      spellfile = "${config.home.homeDirectory}/.spell/en.utf-8.add"; # Use config variable

      # Set tabs to 2 spaces
      tabstop = 2;
      softtabstop = 2;
      showtabline = 2;
      expandtab = true;

      # Enable auto indenting and set it to spaces
      smartindent = true;
      shiftwidth = 2;

      breakindent = true;
      linebreak = true;
      showbreak = "↳";

      # Enable incremental searching
      hlsearch = true;
      incsearch = true;

      # Enable text wrap
      wrap = true;

      # Better splitting
      splitbelow = true;
      splitright = true;

      # Enable mouse mode
      mouse = "a";
      mousemoveevent = true;

      # Enable ignorecase + smartcase for better searching
      ignorecase = true;
      smartcase = true;
      grepprg = "rg --vimgrep";
      grepformat = "%f:%l:%c:%m";

      # Decrease updatetime
      updatetime = 250;

      # Enable persistent undo history
      swapfile = false;
      backup = false;
      writebackup = false;
      undofile = true;

      # Enable 24-bit colors
      termguicolors = true;

      # Enable the sign column to prevent the screen from jumping
      signcolumn = "yes";

      # Enable cursor line highlight
      cursorline = true;
      cursorlineopt = "number";

      # Fold settings
      # Enhanced folding configuration for better usability
      # foldcolumn = "auto:1"; # Show fold column with indicators
      foldlevel = 99; # Start with all folds open
      foldlevelstart = 99; # Start with all folds open when opening files
      foldenable = true; # Enable folding
      foldmethod = "expr"; # Use expression-based # Enable folding
      foldexpr = "nvim_treesitter#foldexpr()"; # Use treesitter for folding
      foldminlines = 1; # Minimum lines for a fold
      foldnestmax = 3; # Maximum fold nesting level
      fillchars = {
        vert = "│"; # Use vertical line for fold column
        fold = "·"; # Use centered dot for fold indicator
        foldopen = "▾"; # Use triangle for open folds
        foldclose = "▸"; # Use triangle for closed folds
        foldsep = "│"; # Use vertical line for fold separator
      };

      # Always keep 5 lines above/below cursor unless at start/end of file
      scrolloff = 3;
      sidescrolloff = 5;

      # Place a column line
      # colorcolumn = "80";

      # Reduce which-key timeout to 10ms
      timeoutlen = 300;

      # Set encoding type
      encoding = "utf-8";
      fileencoding = "utf-8";

      # More space in the neovim command line for displaying messages
      laststatus = 3;
      cmdheight = 1;
      showmode = false; # We don't need to see things like INSERT anymore

      pumheight = 0; # Use available space for completion menu

      # Neovim 0.11: Set default border for floating windows (LSP hover, etc.)
      winborder = "rounded"; # Options: none, single, double, rounded, solid, shadow
    };
  };
}
