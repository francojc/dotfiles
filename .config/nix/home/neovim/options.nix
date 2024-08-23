{
  programs.nixvim = {

    globals = {
      loaded_ruby_provider = 0;
      loaded_perl_provider = 0;
      copilot_no_tab_map = 1;
    };

    opts = {
      # Enable relative line numbers
      number = true;
      relativenumber = true;
      clipboard = "unnamedplus";

      # Spell
      spell = false; # set spell off by default
      spelllang = "en_us";
      spellfile = "/Users/francojc/.spell/en.utf-8.add"; # INFO: Not very portable, but works

      # Set tabs to 2 spaces
      tabstop = 2;
      softtabstop = 2;
      showtabline = 2;
      expandtab = true;

      # Enable auto indenting and set it to spaces
      smartindent = true;
      shiftwidth = 2;

      # Enable smart indenting (see https://stackoverflow.com/questions/1204149/smart-wrap-in-vim)
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
      mouse = "a"; # Mouse

      # Enable ignorecase + smartcase for better searching
      ignorecase = true;
      smartcase = true; # Don't ignore case with capitals
      grepprg = "rg --vimgrep";
      grepformat = "%f:%l:%c:%m";

      # Decrease updatetime
      updatetime = 50; # faster completion (4000ms default)

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
      cursorline = true; # Highlight the line where the cursor is located
      cursorlineopt = "number";

      # Set fold settings
      # These options were reccommended by nvim-ufo
      # See: https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
      foldcolumn = "0";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;

      # Always keep 5 lines above/below cursor unless at start/end of file
      scrolloff = 5;
      sidescrolloff = 5;

      # Place a column line
      # colorcolumn = "80";

      # Reduce which-key timeout to 10ms
      timeoutlen = 200;

      # Set encoding type
      encoding = "utf-8";
      fileencoding = "utf-8";

      # More space in the neovim command line for displaying messages
      cmdheight = 0;

      # We don't need to see things like INSERT anymore
      showmode = true; # TODO: return after lualine installed
    };
  };
}
