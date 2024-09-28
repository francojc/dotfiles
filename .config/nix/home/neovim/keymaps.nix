{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      {
        mode = "i";
        key = "jj";
        action = "<Esc>";
        options = {
          desc = "jj to esc";
          silent = true;
        };
      }

      {
        mode = "i";
        key = "<C-d>";
        action = "<Plug>(copilot-accept-word)";
        options = { desc = "Copilot: accept next word"; };
      }
      {
        mode = "i";
        key = "<C-f>";
        action = "<Plug>(copilot-accept-line)";
        options = { desc = "Copilot: accept next line"; };
      }
      {
        mode = "i";
        key = "<C-g>";
        action = "<Cmd>lua copilot#Accept(1)<CR>";
        options = { desc = "Copilot: accept suggestion"; };
      }
      {
        mode = "i";
        key = "<C-y>";
        action = "<Plug>(copilot-next)";
        options = { desc = "Copilot: next suggestion"; };
      }
      {
        mode = "i";
        key = "<C-e>";
        action = "<Plug>(copilot-dismiss)";
        options = { desc = "Copilot: dismiss suggestion"; };
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
        options = {
          expr = true;
          desc = "Move down visual line";
        };
      }

      {
        mode = "n";
        key = "<Tab>";
        action = "<cmd>BufferLineCycleNext<cr>";
        options = { desc = "Cycle to next buffer"; };
      }

      {
        mode = "n";
        key = "<S-Tab>";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options = { desc = "Cycle to previous buffer"; };
      }

      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>BufferLineCycleNext<cr>";
        options = { desc = "Cycle to next buffer"; };
      }

      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options = { desc = "Cycle to previous buffer"; };
      }

      {
        mode = "n";
        key = "k";
        action = "v:count == 0 ? 'gk' : 'k'";
        options = {
          expr = true;
          desc = "Move up visual line";
        };
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

      # Assistants
      {
        mode = "n";
        key = "<leader>ag";
        action = "<Cmd>CopilotChat<CR>";
        options = { desc = "GitHub Copilot"; };
      }
      {
        mode = "x";
        key = "<leader>ae";
        action = "<cmd>CopilotChatExplain<cr>";
      }
      {
        mode = "x";
        key = "<leader>af";
        action = "<cmd>CopilotChatFix<cr>";
      }
      {
        mode = "x";
        key = "<leader>ad";
        action = "<cmd>CopilotChatDocs<cr>";
      }
      {
        mode = "x";
        key = "<leader>ac";
        action = "<cmd>CopilotChatCommit<cr>";
      }

      {
        mode = "n";
        key = "<leader>ac";
        action = "<Cmd>CodeCompanionActions<CR>";
        options = { desc = "CodeCompanion Actions"; };
      }

      # Buffers

      {
        mode = "n";
        key = "<leader>bn";
        action = "<cmd>tabnew<cr>";
        options = { desc = "New buffer"; };
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>bdelete<cr>";
        options = { desc = "Delete buffer"; };
      }

      {
        mode = "n";
        key = "<leader>bb";
        action = "<cmd>e #<cr>";
        options = { desc = "Switch to Other Buffer"; };
      }

      {
        mode = "n";
        key = "<leader>br";
        action = "<cmd>BufferLineCloseRight<cr>";
        options = { desc = "Delete buffers to the right"; };
      }

      {
        mode = "n";
        key = "<leader>bl";
        action = "<cmd>BufferLineCloseLeft<cr>";
        options = { desc = "Delete buffers to the left"; };
      }

      {
        mode = "n";
        key = "<leader>bo";
        action = "<cmd>BufferLineCloseOthers<cr>";
        options = { desc = "Delete other buffers"; };
      }

      {
        mode = "n";
        key = "<leader>bp";
        action = "<cmd>BufferLineTogglePin<cr>";
        options = { desc = "Toggle pin"; };
      }

      {
        mode = "n";
        key = "<leader>bP";
        action = "<Cmd>BufferLineGroupClose ungrouped<CR>";
        options = { desc = "Delete non-pinned buffers"; };
      }

      # Code
      {
        mode = "n";
        key = "<C-c>";
        action = "<Plug>SlimeParagraphSend<CR>";
        options = { desc = "Send code phrase"; };
      }
      {
        mode = "x";
        key = "<C-c>";
        action = "<Plug>SlimeRegionSend<CR>";
        options = { desc = "Send selected code region"; };
      }
      {
        mode = "n";
        key = "<C-CR>";
        action = "<Cmd>QuartoSend<CR>";
        options = { desc = "Quarto: Send cell"; };
      }

      {
        mode = "n";
        key = "<leader>ca";
        action = "<Cmd>Lspsaga code_action<CR>";
        options = { desc = "Code action"; };
      }

      {
        mode = [ "n" "v" ];
        key = "<leader>cf";
        action = "<cmd>lua vim.lsp.buf.format()<cr>";
        options = {
          silent = true;
          desc = "Code format";
        };
      }
      # Debug
      # (e)

      # Files
      {
        mode = "n";
        key = "<leader>ft";
        action = "<Cmd>NvimTreeToggle<CR>";
        options = { desc = "Open Directory Viewer"; };
      }
      {
        mode = "n";
        key = "<leader>fn";
        action = "<Cmd>ene <bar> startinsert<CR>";
        options = { desc = "New File"; };
      }
      {
        mode = "n";
        key = "<leader>fy";
        action = "<Cmd>lua require('yazi').yazi()<CR>";
        options = { desc = "Yazi"; };
      }

      # Git
      {
        mode = "n";
        key = "<leader>gg";
        action = "<Cmd>LazyGit<CR>";
        options = { desc = "LazyGit"; };
      }

      # Obsidian
      {
        mode = "n";
        key = "<leader>od";
        action = "<Cmd>ObsidianDailies<CR>";
        options = { desc = "Daily note"; };
      }
      {
        mode = "n";
        key = "<leader>on";
        action = "<Cmd>ObsidianNew<CR>";
        options = { desc = "New note"; };
      }
      {
        mode = "n";
        key = "<leader>oN";
        action = "<Cmd>ObsidianNewFromTemplate<CR>";
        options = { desc = "New note from template"; };
      }
      {
        mode = "n";
        key = "<leader>ot";
        action = "<Cmd>ObsidianToday<CR>";
        options = { desc = "Today's note"; };
      }
      {
        mode = "n";
        key = "<leader>os";
        action = "<Cmd>ObsidianSearch<CR>";
        options = { desc = "Search notes"; };
      }
      {
        mode = "n";
        key = "<leader>oS";
        action = "<Cmd>ObsidianQuickSwitch<CR>";

        options = { desc = "Quick switch between notes"; };
      }
      {
        mode = "n";
        key = "<leader>ot";
        action = "<Cmd>ObsidianTags<CR>";
        options = { desc = "Search notes by tags/ list tags"; };
      }
      {
        mode = "n";
        key = "<leader>oi";
        action = "<Cmd>ObsidianPasteImg<CR>";
        options = { desc = "Paste image from clipboard"; };
      }
      {
        mode = "n";
        key = "<leader>or";
        action = "<Cmd>ObsidianRename<CR>";
        options = { desc = "Rename note"; };
      }
      {
        mode = "n";
        key = "<leader>oo";
        action = "<Cmd>ObsidianTOC<CR>";
        options = { desc = "Open note outline"; };
      }
      {
        mode = "n";
        key = "<leader>ol";
        action = "<Cmd>ObsidianLink<CR>";
        options = { desc = "Insert link to existing note"; };
      }
      {
        mode = "n";
        key = "<leader>oL";
        action = "<Cmd>ObsidianLinkNew<CR>";
        options = { desc = "Insert link to new note from selection"; };
      }

      # Quarto
      {
        mode = "n";
        key = "<leader>qa";
        action = "<Cmd>QuartoSendAbove<CR>";
        options = { desc = "Quarto: Send chunks above"; };
      }

      {
        mode = "n";
        key = "<leader>qb";
        action = "<Cmd>QuartoSendBelow<CR>";
        options = { desc = "Quarto: Send chunks below"; };
      }
      {
        mode = "n";
        key = "<leader>qd";
        action = "<Cmd>QuartoDiagnostics<CR>";
        options = { desc = "Quarto: Diagnostics"; };
      }
      {
        mode = "n";
        key = "<leader>qf";
        action = "<Cmd>QuartoSendAll<CR>";
        options = { desc = "Quarto: Send file (all chunks)"; };
      }
      {
        mode = "n";
        key = "<leader>qp";
        action = "<Cmd>QuartoPreview<CR>";
        options = { desc = "Quarto: Preview"; };
      }
      {
        mode = "n";
        key = "<leader>qx";
        action = "<Cmd>QuartoClosePreview<CR>";
        options = { desc = "Quarto: Close preview"; };
      }
      {
        mode = "n";
        key = "<leader>qs";
        action = "<Cmd>QuartoActivate<CR>";
        options = { desc = "Quarto: Start"; };
      }
      # Search
      {
        mode = "n";
        key = "<leader>st";
        action = "<Cmd>TodoTelescope<CR>";
        options = { desc = "Search Todos"; };
      }

      # Terminal
      {
        mode = "n";
        key = "<leader>ts";
        action = "<Cmd>SlimeConfig<CR>";
        options = { desc = "Set slime config"; };
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
        key = "<leader>\\c";
        action = "<Cmd>toggle_conceallevel()<CR>";
        options = { desc = "Toggle Conceal Level"; };
      }
      {
        mode = "n";
        key = "<leader>\\m";
        action = "<Cmd>Markview toggle<CR>";
        options = { desc = "Toggle Markview (non-active)"; };
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
        options = { desc = "Toggle Precognition (non-active)"; };
      }
      {
        mode = "n";
        key = "<leader>\\r";
        action = "<Cmd>lua toggle_r_lsp()<CR>";
        options = { desc = "Toggle R LSP"; };
      }
      {
        mode = "n";
        key = "<leader>\\s";
        action = "<Cmd>set spell!<CR>";
        options = { desc = "Toggle Spell"; };
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
        key = "<leader>x";
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

      {
        mode = [ "n" "x" "o" ];
        key = "s";
        action = "<cmd>lua require('flash').jump()<cr>";
        options = {
          desc = "Flash";
        };
      }

      {
        mode = [ "n" "x" "o" ];
        key = "S";
        action = "<cmd>lua require('flash').treesitter()<cr>";
        options = {
          desc = "Flash Treesitter";
        };
      }

      {
        mode = "o";
        key = "r";
        action = "<cmd>lua require('flash').remote()<cr>";
        options = {
          desc = "Remote Flash";
        };
      }

      {
        mode = [ "x" "o" ];
        key = "R";
        action = "<cmd>lua require('flash').treesitter_search()<cr>";
        options = {
          desc = "Treesitter Search";
        };
      }
    ];
  };
}
