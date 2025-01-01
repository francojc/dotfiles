{pkgs, ...}: {
  # Plugins: more config
  imports = [
    ./alpha.nix
    ./bufferline.nix
    ./conform.nix
    ./fidget.nix
    ./lualine.nix
    ./lspsaga.nix
    ./none-ls.nix
    ./obsidian.nix
    ./slime.nix
    ./treesitter.nix
    ./which-key.nix
  ];

  # Plugins: basic config
  programs.nixvim = {
    colorschemes = {
      gruvbox = {
        enable = false;
        settings = {
          contrast_dark = "hard";
          contrast_light = "hard";
        };
      };
      onedark = {
        enable = true;
        settings = {
          style = "warmer";
        };
      };
    };
    plugins = {
      auto-session = {
        enable = true;
        settings = {
          bypass_save_filetypes = ["alpha" "NvimTree" "term"];
        };
      };
      avante = {
        enable = false;
        settings = {
          hints.enabled = true;
          provider = "copilot";
          claude = {
            endpoint = "https://api.anthropic.com";
            max_tokens = 4096;
            model = "claude-3-5-sonnet-latest";
            temperature = 0.3;
          };
          copilot = {
            model = "claude-3.5-sonnet";
          };
          windows = {
            wrap = true;
            sidebar_header = {
              enabled = true;
              align = "right";
              rounded = false;
            };
          };
        };
      };
      cmp-pandoc-nvim.enable = true;
      copilot-vim = {enable = true;};
      copilot-chat = {
        enable = true;
        settings = {
          answer_header = "  ";
          error_header = "  ";
          question_header = "  ";
          separator = "───";
          model = "claude-3.5-sonnet";
          temperature = 0.3;
        };
      };
      diffview.enable = true;
      dressing.enable = true;
      flash = {
        enable = true;
      };
      fzf-lua = {
        enable = true;
      };
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
        settings.signs = {
          add = {text = "│";};
          change = {text = "│";};
          delete = {text = "_";};
          topdelete = {text = "‾";};
          changedelete = {text = "~";};
          untracked = {text = "┆";};
        };
      };
      image = {
        enable = true;
        integrations = {
          markdown = {
            filetypes = ["markdown" "quarto" "rmd"];
            clearInInsertMode = true;
            onlyRenderImageAtCursor = true;
          };
        };
        maxHeightWindowPercentage = 25;
      };
      lazygit.enable = true;
      mini = {
        enable = true;
        modules = {
          indentscope = {};
          icons = {};
        };
      };
      nix.enable = true;
      notify = {
        enable = true;
        timeout = 3000;
        topDown = false;
      };
      nvim-autopairs.enable = true;
      colorizer = {
        enable = true;
        settings = {
          filetypes = ["*"];
          user_default_options = {
            mode = "virtualtext";
            virtualtext = "■";
            names = false;
            RGB = true;
            RRGGBB = true;
            RRGGBBAA = true;
          };
        };
      };
      nvim-tree = {
        enable = true;
        view.side = "left";
        hijackCursor = true;
        modified.enable = true;
        renderer = {
          highlightGit = true;
          rootFolderLabel = false;
          icons = {
            gitPlacement = "signcolumn";
            modifiedPlacement = "signcolumn";
          };
        };
      };
      otter.enable = true;
      render-markdown = {
        enable = true;
        settings = {
          bullet = {
            icons = ["■" "□" "◆" "◇"];
            right_pad = 1;
          };
          code = {
            code = {
              above = " ";
              below = " ";
              border = "thick";
              language_pad = 2;
              position = "right";
              right_pad = 2;
              sign = false;
              width = "block";
            };
          };
          heading = {
            border = true;
            position = "inline";
            icons = [
              "1| "
              "2| "
              "3| "
              "4| "
              "5| "
              "6| "
            ];
            sign = false;
            width = "full";
          };
          render_modes = true;
          signs.enabled = false;
          file_types = ["markdown" "quarto" "rmd" "copilot-chat"];
          win_options = {
            conceallevel.rendered = 0;
          };
        };
      };

      spectre.enable = true;
      todo-comments.enable = true;
      toggleterm = {
        enable = true;
        settings = {
          direction = "vertical";
          open_mapping = "[[<C-t>]]";
          size = 50;
        };
      };
      trouble.enable = true;
      vim-surround.enable = true;
      web-devicons.enable = true;
      yazi.enable = true;
    };

    # extraPlugins
    extraPlugins = [
      pkgs.vimPlugins.aerial-nvim
      pkgs.vimPlugins.dropbar-nvim
      pkgs.vimPlugins.quarto-nvim
    ];

    # Lua config
    extraConfigLua = ''
      -- Aerial setup
      require("aerial").setup({
        on_attach = function(bufnr)
          -- jump forward and backward
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
        -- keymap to toggle the aerial window
        vim.keymap.set("n", "<leader>\\o", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial" })
      })

      -- cmp-pandoc setup
      require("cmp_pandoc").setup({
        -- @type: table of strings
        filetypes = { "markdown", "quarto", "rmd" },
        bibliography =  {
          documentation = true,
          fields = {
            "author",
            "title",
            "year"
          },
        },
        crossref = {
          documentation = true,
        },
      })

      -- Quarto setup
      require("quarto").setup({
        debug = false,
        closePreviewOnExit = true,
        lspFeatures = {
          enabled = true,
          languages = { "r", "python", "bash", "html" },
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
          enabled = true,
          },
        },
      })

      -- Keymaps for navigating Toggleterm terminal windows
      vim.keymap.set('t', 'jj', [[<C-\><C-n>]])

      --- Note: I only need to esc and change windows with
      --- C-h and C-j as I only open ToggleTerm in vert and horz
      vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]])
      vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]])
      vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]])

      -- Special keymapings
      -- Markdown --

      -- Unordered list
      vim.keymap.set("n", "<leader>mu", "i- ", { desc = "Unordered list item", silent = true })
      vim.keymap.set("v", "<leader>mu", ":s/^/- /<CR>gv", { desc = "Unordered list item", silent = true })

      -- Task list
      vim.keymap.set("n", "<leader>mt", "i- [ ] ", { desc = "Task item", silent = true })
      vim.keymap.set("v", "<leader>mt", ":s/^/- [ ] /<CR>gv", { desc = "Task item", silent = true })

      -- Styled text
      vim.keymap.set("v", "<leader>mb", "c**<C-r>\"**<Esc>", { desc = "Bold", silent = true })
      vim.keymap.set("v", "<leader>mi", "c*<C-r>\"*<Esc>", { desc = "Italic", silent = true })
      vim.keymap.set({"n", "v"}, "<leader>ms", "c~~<C-r>\"~~<Esc>", { desc = "Strikethrough", silent = true })

      -- Links
      vim.keymap.set("v", "<leader>ml", "c[<C-r>\"](<C-r>+)<Esc>", { desc = "Add Link", silent = true })

      -- Code blocks
      vim.keymap.set("v", "<leader>mc", "c```\n<C-r>\"\n```<Esc>", { desc = "Code Block", silent = true })
      vim.keymap.set("v", "<leader>mk", "c`<C-r>\"`<Esc>", { desc = "Inline Code", silent = true })

      -- Headers
      vim.keymap.set({"n", "v"}, "<leader>m1", "I# ", { desc = "H1", silent = true })
      vim.keymap.set({"n", "v"}, "<leader>m2", "I## ", { desc = "H2", silent = true })
      vim.keymap.set({"n", "v"}, "<leader>m3", "I### ", { desc = "H3", silent = true })

      -- Spell Language Functionality
      local function get_project_root()
        local current_file = vim.fn.expand('%:p')
        if current_file == "" then
          return nil
        end
        local path = vim.fn.fnamemodify(current_file, ':h')
        while path ~= "" and path ~= "/" do
          if vim.fn.isdirectory(path .. "/.git") == 1 or vim.fn.isdirectory(path .. "/.nvim_spell_lang") == 1 then
            return path
          end
          path = vim.fn.fnamemodify(path, ':h')
        end
        return nil
      end

      local function load_spell_lang()
        local project_root = get_project_root()
        if not project_root then
          return
        end
        local spell_lang_file = project_root .. "/.nvim_spell_lang"
        if vim.fn.filereadable(spell_lang_file) == 1 then
          local lang = vim.trim(vim.fn.readfile(spell_lang_file)[1])
          vim.opt_local.spelllang = lang
        else
          vim.opt_local.spelllang = "en_us"
        end
      end

      local function set_spell_lang(lang)
        local project_root = get_project_root()
        if not project_root then
          return
        end
        local spell_lang_file = project_root .. "/.nvim_spell_lang"
        vim.fn.writefile({lang}, spell_lang_file)
        vim.opt_local.spelllang = lang
      end

      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          load_spell_lang()
        end,
      })

      vim.api.nvim_create_user_command("SpellLang", function()
        vim.ui.select(
          { "en_us", "es" },
          {
            prompt = "Select spell language:",
          },
          function(choice)
            if choice then
              set_spell_lang(choice)
            end
          end
        )
      end, {})
    '';
  };
}
