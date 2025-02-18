{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
    # Remappings
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
        mode = "n";
        key = "k";
        action = "v:count == 0 ? 'gk' : 'k'";
        options = {
          expr = true;
          desc = "Move up visual line";
        };
      }
      {
        mode = ["n" "v"];
        key = "gl";
        action = "g_";
        options = {desc = "Move to last non-blank character";};
      }
      {
        mode = "i";
        key = "<C-e>";
        action = "<Plug>(copilot-dismiss)";
        options = {desc = "Copilot: dismiss suggestion";};
      }
      {
        mode = "i";
        key = "<C-d>";
        action = "<Plug>(copilot-accept-word)";
        options = {desc = "Copilot: accept next word";};
      }
      {
        mode = "i";
        key = "<C-f>";
        action = "<Plug>(copilot-accept-line)";
        options = {desc = "Copilot: accept next line";};
      }
      {
        mode = "i";
        key = "<C-n>";
        action = "<Plug>(copilot-next)";
        options = {desc = "Copilot: request next suggestion";};
      }
      {
        mode = "i";
        key = "<C-p>";
        action = "<Plug>(copilot-previous)";
        options = {desc = "Copilot: request previous suggestion";};
      }
      {
        mode = "n";
        key = "-";
        action = "<Cmd>lua require('dropbar.api').pick()<CR>";
        options = {desc = "Dropbar picker";};
      }
      # Yank
      {
        mode = "n";
        key = "<leader>y";
        action = "ggVGy";
        options = {desc = "Yank buffer contents";};
      }

      # Accept suggestion <TAB>
      {
        mode = "i";
        key = "<C-j>";
        action = "<Plug>(copilot-next)";
        options = {desc = "Copilot: next suggestion";};
      }
      {
        mode = "i";
        key = "<C-k>";
        action = "<Plug>(copilot-previous)";
        options = {desc = "Copilot: previous suggestion";};
      }
      {
        mode = "i";
        key = "<C-e>";
        action = "<Plug>(copilot-dismiss)";
        options = {desc = "Copilot: escape suggestion";};
      }

      {
        mode = "n";
        key = "<C-s>";
        action = "<Cmd>w!<CR>";
        options = {desc = "Save file!";};
      }

      {
        mode = "n";
        key = "<C-S>";
        action = "<Cmd>wa!<CR>";
        options = {desc = "Save all!";};
      }

      {
        mode = "n";
        key = "<Esc>";
        action = "<Esc><Cmd>nohlsearch<CR>";
        options = {desc = "Use <Esc> to remove highlighting";};
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
        options = {desc = "Cycle to next buffer";};
      }

      {
        mode = "n";
        key = "<S-Tab>";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options = {desc = "Cycle to previous buffer";};
      }

      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>BufferLineCycleNext<cr>";
        options = {desc = "Cycle to next buffer";};
      }

      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options = {desc = "Cycle to previous buffer";};
      }


      # Assistants

      # -- Normal mode
      {
        mode = "n";
        key = "<leader>ag";
        action = "<Cmd>CopilotChat<CR>";
        options = {desc = "GitHub Copilot";};
      }
      {
        mode = "x";
        key = "<leader>af";
        action = "<cmd>CopilotChatFix<cr>";
        options = {desc = "Copilot fix";};
      }
      {
        mode = "x";
        key = "<leader>ad";
        action = "<cmd>CopilotChatDocs<cr>";
        options = {desc = "Copilot add documentation";};
      }
      {
        mode = "x";
        key = "<leader>ac";
        action = "<cmd>CopilotChatCommit<cr>";
        options = {desc = "Copilot commit";};
      }
      {
        mode = "x";
        key = "<leader>ax";
        action = "<cmd>CopilotChatExplain<cr>";
        options = {desc = "Copilot explain";};
      }

      # Buffers
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>lua Snacks.bufdelete.delete()<cr>";
        options.desc = "Delete buffer";
      }

      {
        mode = "n";
        key = "<leader>bb";
        action = "<cmd>e #<cr>";
        options = {desc = "Switch to Other Buffer";};
      }

      {
        mode = "n";
        key = "<leader>bh";
        action = "<cmd>BufferLineCloseLeft<cr>";
        options = {desc = "Delete buffers: left (h)";};
      }

      {
        mode = "n";
        key = "<leader>bl";
        action = "<cmd>BufferLineCloseRight<cr>";
        options = {desc = "Delete buffers: right (l)";};
      }

      {
        mode = "n";
        key = "<leader>bs";
        action = "<cmd>BufferLineSortByDirectory<cr>";
        options = {desc = "Sort buffers by directory";};
      }

      {
        mode = "n";
        key = "<leader>bS";
        action = "<cmd>BufferLineSortByExtension<cr>";
        options = {desc = "Sort buffers by extension";};
      }

      {
        mode = "n";
        key = "<leader>bo";
        action = "<cmd>BufferLineCloseOthers<cr>";
        options = {desc = "Delete other buffers";};
      }

      {
        mode = "n";
        key = "<leader>bp";
        action = "<cmd>BufferLineTogglePin<cr>";
        options = {desc = "Toggle pin";};
      }

      {
        mode = "n";
        key = "<leader>bP";
        action = "<Cmd>BufferLineGroupClose ungrouped<CR>";
        options = {desc = "Delete non-pinned buffers";};
      }

      # Code
      {
        mode = "x";  # Visual mode
        key = "<leader>cn";
        action = ":s/\\s\\+/ /g<CR>";
        options = {
          desc = "Normalize whitespace in selection";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<C-c>";
        action = "<Plug>SlimeParagraphSend<CR>";
        options = {desc = "Send code phrase";};
      }
      {
        mode = "x";
        key = "<C-c>";
        action = "<Plug>SlimeRegionSend<CR>";
        options = {desc = "Send selected code region";};
      }
      {
        mode = "n";
        key = "<C-CR>";
        action = "<Cmd>QuartoSend<CR>";
        options = {desc = "Quarto: Send cell";};
      }

      {
        mode = "n";
        key = "<leader>ca";
        action = "<Cmd>lua require('fzf-lua').lsp_code_actions()<CR>";
        options = {desc = "Show code actions";};
      }

      {
        mode = ["n" "v"];
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
        options = {desc = "Open Directory Viewer";};
      }
      {
        mode = "n";
        key = "<leader>fn";
        action = "<Cmd>ene <bar> startinsert<CR>";
        options = {desc = "New File";};
      }
      {
        mode = "n";
        key = "<leader>fy";
        action = "<Cmd>lua require('yazi').yazi()<CR>";
        options = {desc = "Yazi";};
      }

      {
        mode = "n";
        key = "<leader>ff";
        action = "<Cmd>lua require('fzf-lua').files()<CR>";
        options = {desc = "Find files";};
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = "<Cmd>lua require('fzf-lua').oldfiles()<CR>";
        options = {desc = "Find recent files";};
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<Cmd>lua require('fzf-lua').buffers()<CR>";
        options = {desc = "Find buffer files";};
      }
      {
        mode = "n";
        key = "<leader>fs";
        action = "<Cmd>lua require('fzf-lua').treesitter()<CR>";
        options = {desc = "Find buffer symbols";};
      }

      # Git
      {
        mode = [ "n" "v" ];
        key = "<leader>gb";
        action = "<Cmd>lua Snacks.gitbrowse.open()<CR>";
        options.desc = "Open gitbrowse";
      }

      {
        mode = "n";
        key = "<leader>gg";
        action = "<Cmd>LazyGit<CR>";
        options = {desc = "LazyGit";};
      }
      {
        mode = "n";
        key = "<leader>gf";
        action = "<Cmd>lua require('fzf-lua').git_files()<CR>";
        options = {desc = "Git files";};
      }
      {
        mode = "n";
        key = "<leader>gs";
        action = "<Cmd>lua require('fzf-lua').git_status()<CR>";
        options = {desc = "Git files";};
      }
      # LSP
      {
        mode = "n";
        key = "<leader>ld";
        action = "<Cmd>lua require('fzf-lua').diagnostics_document()<CR>";
        options = {desc = "Document diagnostics";};
      }
      {
        mode = "n";
        key = "<leader>lD";
        action = "<Cmd>lua require('fzf-lua').diagnostics_workspace()<CR>";
        options = {desc = "Workspace diagnostics";};
      }

      # Help

      {
        mode = "n";
        key = "<leader>hk";
        action = "<Cmd>lua require('fzf-lua').keymaps()<CR>";
        options.desc = "Help keymaps";
      }
      {
        mode = "n";
        key = "<leader>hc";
        action = "<Cmd>lua require('fzf-lua').commands()<CR>";
        options.desc = "Help Neovim commands";
      }



      # Markdown

      # Obsidian
      {
        mode = "n";
        key = "<leader>od";
        action = "<Cmd>ObsidianDailies<CR>";
        options = {desc = "Daily notes";};
      }
      {
        mode = "n";
        key = "<leader>on";
        action = "<Cmd>ObsidianNew<CR>";
        options = {desc = "New note";};
      }
      {
        mode = "n";
        key = "<leader>oN";
        action = "<Cmd>ObsidianNewFromTemplate<CR>";
        options = {desc = "New note from template";};
      }
      {
        mode = "n";
        key = "<leader>ot";
        action = "<Cmd>ObsidianToday<CR>";
        options = {desc = "Today's note";};
      }
      {
        mode = "n";
        key = "<leader>os";
        action = "<Cmd>ObsidianSearch<CR>";
        options = {desc = "Search notes";};
      }
      {
        mode = "n";
        key = "<leader>oS";
        action = "<Cmd>ObsidianQuickSwitch<CR>";

        options = {desc = "Quick switch between notes";};
      }
      {
        mode = "n";
        key = "<leader>ot";
        action = "<Cmd>ObsidianTags<CR>";
        options = {desc = "Search notes by tags/ list tags";};
      }
      {
        mode = "n";
        key = "<leader>oi";
        action = "<Cmd>ObsidianPasteImg<CR>";
        options = {desc = "Paste image from clipboard";};
      }
      {
        mode = "n";
        key = "<leader>or";
        action = "<Cmd>ObsidianRename<CR>";
        options = {desc = "Rename note";};
      }
      {
        mode = "n";
        key = "<leader>oo";
        action = "<Cmd>ObsidianTOC<CR>";
        options = {desc = "Open note outline";};
      }
      {
        mode = "n";
        key = "<leader>ol";
        action = "<Cmd>ObsidianLink<CR>";
        options = {desc = "Insert link to existing note";};
      }
      {
        mode = "n";
        key = "<leader>oL";
        action = "<Cmd>ObsidianLinkNew<CR>";
        options = {desc = "Insert link to new note from selection";};
      }

      # Copy/ Paste
      {
        mode = "n";
        key = "<leader>pi";
        action = "<Cmd>lua require('img-clip').paste_image({dir_path = 'images', relative_to_current_file = true })<CR>";
        options = {desc = "Paste image from system clipboard";};
      }

      # Quarto
      {
        mode = "n";
        key = "<leader>qa";
        action = "<Cmd>QuartoSendAbove<CR>";
        options = {desc = "Quarto: Send chunks above";};
      }

      {
        mode = "n";
        key = "<leader>qb";
        action = "<Cmd>QuartoSendBelow<CR>";
        options = {desc = "Quarto: Send chunks below";};
      }
      {
        mode = "n";
        key = "<leader>qd";
        action = "<Cmd>QuartoDiagnostics<CR>";
        options = {desc = "Quarto: Diagnostics";};
      }
      {
        mode = "n";
        key = "<leader>qf";
        action = "<Cmd>QuartoSendAll<CR>";
        options = {desc = "Quarto: Send file (all chunks)";};
      }
      {
        mode = "n";
        key = "<leader>qp";
        action = "<Cmd>QuartoPreview<CR>";
        options = {desc = "Quarto: Preview";};
      }
      {
        mode = "n";
        key = "<leader>qx";
        action = "<Cmd>QuartoClosePreview<CR>";
        options = {desc = "Quarto: Close preview";};
      }
      {
        mode = "n";
        key = "<leader>qs";
        action = "<Cmd>QuartoActivate<CR>";
        options = {desc = "Quarto: Start";};
      }

      # Search
      {
        mode = "n";
        key = "<leader>sf";
        action = "<Cmd>GrugFar<CR>";
        options = {desc = "Find/ Replace";};
      }
      {
        mode = "n";
        key = "<leader>sg";
        action = "<Cmd>lua require('fzf-lua').live_grep()<CR>";
        options = {desc = "Live grep";};
      }

      {
        mode = "n";
        key = "<leader>sr";
        action = "<Cmd>lua require('fzf-lua').registers()<CR>";
        options = {desc = "Search registers";};
      }

      {
        mode = "n";
        key = "<leader>ss";
        action = "<Cmd>lua require('fzf-lua').spell_suggest()<CR>";
        options = {desc = "Spell suggest";};
      }

      {
        mode = "n";
        key = "<leader>st";
        action = "<Cmd>TodoFzfLua<CR>";
        options = {desc = "Search Todos";};
      }

      # Terminal
      {
        mode = "n";
        key = "<leader>ts";
        action = "<Cmd>SlimeConfig<CR>";
        options = {desc = "Set slime config";};
      }
      {
        mode = ["n"];
        key = "<leader>tt";
        action = "<Cmd>Lspsaga term_toggle<CR>";
        options = {desc = "Term Toggle";};
      }

      # Toggle

      {
        mode = "n";
        key = "<leader>\\o";
        action = "<Cmd>AerialToggle!<CR>";
        options = {desc = "Toggle Aerial";};
      }
      {
        mode = "n";
        key = "<leader>\\p";
        action = "<Cmd>LspStart ruff<CR>";
        options = {desc = "Toggle Python (ruff)";};
      }
      {
        mode = "n";
        key = "<leader>\\t";
        action = "<Cmd>ToggleTerm<CR>";
        options = {desc = "ToggleTerm";};
      }
      {
        mode = "n";
        key = "<leader>\\r";
        action = "<Cmd>LspStart r_language_server<CR>";
        options = {desc = "Toggle R language server";};
      }
      {
        mode = "n";
        key = "<leader>\\s";
        action = "<Cmd>set spell!<CR>";
        options = {desc = "Toggle Spell";};
      }

      # Windows
      {
        mode = "n";
        key = "<leader>wh";
        action = "<cmd>vertical resize +5<cr>";
        options = {
          silent = true;
          desc = "Increase window width";
        };
      }
      {
        mode = "n";
        key = "<leader>wj";
        action = "<cmd>resize -5<cr>";
        options = {
          silent = true;
          desc = "Decrease window height";
        };
      }
      {
        mode = "n";
        key = "<leader>wh";
        action = "<cmd>vertical resize +5<cr>";
        options = {
          silent = true;
          desc = "Increase window width";
        };
      }
      {
        mode = "n";
        key = "<leader>wk";
        action = "<cmd>resize +5<cr>";
        options = {
          silent = true;
          desc = "Increase window height";
        };
      }
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
          desc = "Move to window below";
        };
      }

      # Quit/Session
      {
        mode = "n";
        key = "<leader>x";
        action = "<cmd>quitall<cr><esc>";
        options = {
          silent = true;
          desc = "Quit Neovim";
        };
      }
      {
        mode = "n";
        key = "<leader>X";
        action = "<cmd>%bd | quit<cr>";
        options = {
          silent = true;
          desc = "Quit session";
        };
      }
      # Moving when in visual mode
      {
        mode = "v";
        key = "J";
        action = ":m '>+1<CR>gv=gv";
        options = {desc = "Use move command when line is highlighted ";};
      }

      {
        mode = "v";
        key = "K";
        action = ":m '>-2<CR>gv=gv";
        options = {desc = "Use move command when line is highlighted ";};
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
        options = {desc = "Allow search terms to stay in the middle ";};
      }

      {
        mode = "n";
        key = "N";
        action = "Nzzzv";
        options = {desc = "Allow search terms to stay in the middle ";};
      }

      {
        mode = ["n" "x" "o"];
        key = "m";
        action = "<cmd>lua require('flash').jump()<cr>";
        options = {
          desc = "Flash";
        };
      }

      {
        mode = ["n" "x" "o"];
        key = "M";
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
        mode = ["x" "o"];
        key = "R";
        action = "<cmd>lua require('flash').treesitter_search()<cr>";
        options = {
          desc = "Treesitter Search";
        };
      }
      {
        mode = "n";
        key = "<leader>sl";
        action = "<Cmd>SpellLang<CR>";
        options = {desc = "Select spell language";};
      }
    ];
  };
}
