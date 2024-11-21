{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;
      extensions = {
        file-browser = {
          enable = true;
          settings = {
            grouped = true;
          };
        };
        frecency = {
          enable = true;
          settings = {
            hide_current_buffer = true;
            show_filter_column = false;
            show_scores = false;
          };
        };
        fzf-native.enable = true;
        ui-select.enable = true;
      };
      settings = {
        defaults = {
          layout_config = {
            horizontal = {
              prompt_position = "top";
            };
          };
          sorting_strategy = "ascending";
          path_display = {
            filename_first = {
              reverse_directories = true;
            };
          };
        };
      };
      keymaps = {
        "<leader>ff" = {
          action = "find_files";
          options = {
            desc = "Find project files";
          };
        };
        "<leader>fg" = {
          action = "live_grep";
          options = {
            desc = "Find text";
          };
        };
        "<leader>bs" = {
          action = "buffers";
          options = {
            desc = "Buffers search";
          };
        };
        "<leader>gc" = {
          action = "git_commits";
          options = {
            desc = "Commits";
          };
        };
        "<leader>gs" = {
          action = "git_status";
          options = {
            desc = "Status";
          };
        };
        "<leader>sa" = {
          action = "autocommands";
          options = {
            desc = "Auto Commands";
          };
        };
        "<leader>sb" = {
          action = "current_buffer_fuzzy_find";
          options = {
            desc = "Buffer";
          };
        };
        "<leader>sc" = {
          action = "command_history";
          options = {
            desc = "Command History";
          };
        };
        "<leader>sC" = {
          action = "commands";
          options = {
            desc = "Commands";
          };
        };
        "<leader>sD" = {
          action = "diagnostics";
          options = {
            desc = "Workspace diagnostics";
          };
        };
        "<leader>ht" = {
          action = "help_tags";
          options = {
            desc = "Help pages";
          };
        };
        "<leader>sh" = {
          action = "highlights";
          options = {
            desc = "Search Highlight Groups";
          };
        };
        "<leader>sk" = {
          action = "keymaps";
          options = {
            desc = "Keymaps";
          };
        };
        "<leader>sM" = {
          action = "man_pages";
          options = {
            desc = "Man pages";
          };
        };
        "<leader>sm" = {
          action = "marks";
          options = {
            desc = "Jump to Mark";
          };
        };
        "<leader>hv" = {
          action = "vim_options";
          options = {
            desc = "Options";
          };
        };
        "<leader>sR" = {
          action = "resume";
          options = {
            desc = "Resume";
          };
        };
        "<leader>ss" = {
          action = "spell_suggest";
          options = {
            desc = "Spelling suggestions";
          };
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>sd";
        action = "<cmd>Telescope diagnostics bufnr=0<cr>";
        options = {
          desc = "Document diagnostics";
        };
      }
      {
        mode = "n";
        key = "<leader>fe";
        action = "<cmd>Telescope file_browser<cr>";
        options = {
          desc = "File browser";
        };
      }
      {
        mode = "n";
        key = "<leader>fE";
        action = "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>";
        options = {
          desc = "File browser";
        };
      }
      {
        mode = "n";
        key = "<leader>fF";
        action = "<cmd>Telescope find_files find_command=rg,--hidden,--files<cr>";
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = "<cmd>Telescope frecency workspace=CWD<cr>";
        options = {
          desc = "Recent (cwd)";
        };
      }
      {
        mode = "n";
        key = "<leader>fR";
        action = "<cmd>Telescope frecency<cr>";
        options = {
          desc = "Recent (global)";
        };
      }
    ];
    extraConfigLua = ''
      require("telescope").setup{
        pickers = {
          colorscheme = {
            enable_preview = true
          }
        }
      }
    '';
  };
}
