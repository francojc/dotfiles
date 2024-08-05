[
  # General maps

  # Exit insert mode
  {
    mode = "i";
    key = "jj";
    action = "<Esc>";
    options = { desc = "jj to escape"; silent = true; };
  }

  {
    mode = "n";
    key = "<C-s>";
    action = "<Cmd>w!<CR>";
    options = { desc = "Save file!"; };
  }
  {
    mode = "n";
    key = "<C-a>";
    action = "<Cmd>wa!<CR>";
    options = { desc = "Save all!"; };
  }

  {
    mode = "n";
    key = "<Esc>";
    action = "<Esc><Cmd>nohlsearch<CR>";
    options = { desc = "Use <Esc> to remove highlighting"; };
  }

  {
    mode = "n";
    key = "j";
    action = "v:count == 0 ? 'gj' : 'j'";
    options = { expr = true; desc = "Move down visual line"; };
  }
  {
    mode = "n";
    key = "k";
    action = "v:count == 0 ? 'gk' : 'k'";
    options = { expr = true; desc = "Move up visual line"; };
  }

  {
    mode = "n";
    key = "<leader>q";
    action = "+quit/session";
  }

  {
    mode = "n";
    key = "<leader>u";
    action = "+ui";
  }

  {
    mode = "n";
    key = "<leader><Tab>";
    action = "+tab";
  }
  # Assistants
  {
    mode = "n";
    key = "<leader>ag";
    action = "<Cmd>CopilotChat<CR>";
    options = { desc = "GitHub Copilot"; };
  }
  {
    mode = "n";
    key = "<leader>ac";
    action = "<Cmd>CodeCompanionActions<CR>";
    options = { desc = "CodeCompanion Actions"; };
  }
  # Code
  # Debug
  # (e)
  # Files
  {
    mode = "n";
    key = "<leader>ft";
    action = "<Cmd>NvimTreeToggle<CR>";
    options = { desc = "Toggle Tree"; };
  }
  # Git
  # Obsidian
  {
    mode = "n";
    key = "<leader>o";
    action = "<Cmd>ObsidianToggle<CR>";
    options = { desc = "Obsidian"; };
  }
  # Terminal
  {
    mode = [ "n" ];
    key = "<leader>t";
    action = "+terminal";
  }

  {
    mode = [ "n" ];
    key = "<leader>ts";
    action = "<Cmd>SlimeConfig<CR>";
    options = { desc = "Toggle"; };
  }

  {
    mode = [ "n" ];
    key = "<leader>tt";
    action = "<Cmd>Lspsaga term_toggle<CR>";
    options = { desc = "Term Toggle"; };
  }

  # Toggle
  {
    mode = "n";
    key = "<leader>\\a";
    action = "<Cmd>CodeCompanionToggle<CR>";
    options = { desc = "Toggle Code Companion"; };
  }
  {
    mode = "n";
    key = "<leader>\\o";
    action = "<Cmd>Lspsaga outline<CR>";
    options = { desc = "Toggle Outline"; };
  }
  {
    mode = "n";
    key = "<leader>\\p";
    action = "<Cmd>Precognition toggle<CR>";
    options = { desc = "Toggle Precognition"; };
  }
  {
    mode = "n";
    key = "<leader>\\s";
    action = "<Cmd>set spell!<CR>";
    options = { desc = "Toggle Spell"; };
  }

  # Tabs
  {
    mode = "n";
    key = "<leader><tab><tab>";
    action = "<cmd>tabnew<cr>";
    options = {
      silent = true;
      desc = "New Tab";
    };
  }

  {
    mode = "n";
    key = "<leader><tab>d";
    action = "<cmd>tabclose<cr>";
    options = {
      silent = true;
      desc = "Close tab";
    };
  }

  # Windows
  {
    mode = "n";
    key = "<leader>ww";
    action = "<C-W>p";
    options = {
      silent = true;
      desc = "Other window";
    };
  }

  {
    mode = "n";
    key = "<leader>wd";
    action = "<C-W>c";
    options = {
      silent = true;
      desc = "Delete window";
    };
  }

  {
    mode = "n";
    key = "<leader>w-";
    action = "<C-W>s";
    options = {
      silent = true;
      desc = "Split window below";
    };
  }

  {
    mode = "n";
    key = "<leader>w|";
    action = "<C-W>v";
    options = {
      silent = true;
      desc = "Split window right";
    };
  }

  {
    mode = "n";
    key = "<C-h>";
    action = "<C-W>h";
    options = {
      silent = true;
      desc = "Move to window left";
    };
  }
  {
    mode = "n";
    key = "<C-l>";
    action = "<C-W>l";
    options = {
      silent = true;
      desc = "Move to window right";
    };
  }
  {
    mode = "n";
    key = "<C-k>";
    action = "<C-W>k";
    options = {
      silent = true;
      desc = "Move to window over";
    };
  }
  {
    mode = "n";
    key = "<C-j>";
    action = "<C-W>j";
    options = {
      silent = true;
      desc = "Move to window bellow";
    };
  }

  # Quit/Session
  {
    mode = "n";
    key = "<leader>qq";
    action = "<cmd>quitall<cr><esc>";
    options = {
      silent = true;
      desc = "Quit all";
    };
  }

  # Moving when in visual mode
  {
    mode = "v";
    key = "J";
    action = ":m '>+1<CR>gv=gv";
    options = { desc = "Use move command when line is highlighted "; };
  }

  {
    mode = "v";
    key = "K";
    action = ":m '>-2<CR>gv=gv";
    options = { desc = "Use move command when line is highlighted "; };
  }

  {
    mode = "n";
    key = "J";
    action = "mzJ`z";
    options = {
      desc = "Allow cursor to stay in the same place after appending to current line ";
    };
  }

  {
    mode = "n";
    key = "<C-d>";
    action = "<C-d>zz";
    options = {
      desc = "Allow C-d and C-u to keep the cursor in the middle";
    };
  }

  {
    mode = "n";
    key = "<C-u>";
    action = "<C-u>zz";
    options = {
      desc = "Allow C-d and C-u to keep the cursor in the middle";
    };
  }

  {
    mode = "n";
    key = "n";
    action = "nzzzv";
    options = { desc = "Allow search terms to stay in the middle "; };
  }

  {
    mode = "n";
    key = "N";
    action = "Nzzzv";
    options = { desc = "Allow search terms to stay in the middle "; };
  }

  # Paste stuff without saving the deleted word into the buffer
  {
    mode = "x";
    key = "<leader>yp";
    action = ''"_dP'';
    options = { desc = "Deletes to void register and paste over"; };
  }

]
