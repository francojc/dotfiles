{pkgs, ...}: {
  imports = [
    ./alpha.nix
    ./bufferline.nix
    ./lspsaga.nix
    ./lualine.nix
    ./obsidian.nix
    ./slime.nix
    ./snacks.nix
    ./treesitter.nix
    ./which-key.nix
  ];
  programs.nixvim = {
    colorschemes = {
      # see below for vague.nvim
    };
    plugins = {
      aerial.enable = true;
      auto-session = {
        enable = true;
        settings = {
          bypass_save_filetypes = ["alpha" "NvimTree" "term"];
        };
      };
      conform-nvim = {
        enable = true;
        settings = {
          default_format_opts = {
            lsp_format = "last";
          };
          formatters = {};
          formatters_by_ft = {
            "_" = ["trim_whitespace" "squeeze_blanks"];
          };
        };
      };
      copilot-vim.enable = true;
      copilot-chat = {
        enable = true;
        settings = {
          answer_header = "  ";
          error_header = "  ";
          question_header = "  ";
          separator = "───";
          model = "claude-3.5-sonnet";
          temperature = 0.2;
        };
      };
      diffview.enable = true;
      dropbar = {
        enable = true;
        settings = {
          bar.enable = true;
          sources.terminal.name = "Term";
        };
      };
      fidget.enable = true;
      flash.enable = true;
      fzf-lua = {
        enable = true;
        profile = "fzf-native";
      };
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
        settings.signs = {
          add = {text = "+";}; # Classic plus
          change = {text = "⁞";}; # Circle with dot delete = {text = "✖";}; # Bold X
          topdelete = {text = "⌄";}; # Down arrow
          changedelete = {text = "≠";}; # Not equal
          untracked = {text = "?";}; # Question mark
        };
      };
      grug-far.enable = true;
      image = {
        enable = true;
        editorOnlyRenderWhenFocused = true;
        windowOverlapClearEnabled = true;
        integrations = {
          markdown = {
            filetypes = ["markdown" "quarto" "rmd"];
          };
        };
        maxHeightWindowPercentage = 30;
      };
      lazygit.enable = true;
      leap.enable = false;
      mini = {
        enable = true;
        modules = {
          indentscope = {};
          icons = {};
          pairs = {};
          surround = {};
        };
      };
      nix.enable = true;
      notify.enable = true;
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
      # nvim-tree = {
      #   enable = true;
      #   view.side = "left";
      #   hijackCursor = true;
      #   modified.enable = true;
      #   renderer = {
      #     highlightGit = true;
      #     rootFolderLabel = false;
      #     icons = {
      #       gitPlacement = "signcolumn";
      #       modifiedPlacement = "signcolumn";
      #     };
      #   };
      # };
      otter.enable = true;
      quarto.enable = true;
      render-markdown = {
        enable = true;
        settings = {
          anti_conceal = {
            enabled = true;
          };
          bullet = {
            icons = [
              "■ "
              "□ "
              "▪ "
              "▫ "
            ];
          };
          dash.enabled = false;
          file_types = ["markdown" "quarto" "rmd"];
          heading = {
            icons = [
              "# "
              "## "
              "### "
              "#### "
              "##### "
              "###### "
            ];
          };
          html.comment.conceal = false;
          render_modes = ["n" "c" "t"];
        };
      };
      todo-comments.enable = true;
      toggleterm = {
        enable = true;
        settings = {
          auto_scroll = true;
          direction = "horizontal";
          open_mapping = "[[<C-t>]]";
          size = 10;
        };
      };
      trouble.enable = true;
      web-devicons.enable = true;
      yazi.enable = true;
    };

    # extraPlugin

    extraPlugins = [
      # vague.nvim
      (pkgs.vimUtils.buildVimPlugin {
        name = "vague.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "vague2k";
          repo = "vague.nvim";
          rev = "ce5d6c99c8a4545f2133a8be93d54ce424ab857a";
          hash = "sha256-9CAsNvxZM0Kc6wTzRChy2aLVemiutMh9vHsuxkhrhfk=";
        };
      })

      # img-clip.nvim
      (pkgs.vimUtils.buildVimPlugin {
        name = "img-clip.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "HakonHarnes";
          repo = "img-clip.nvim";
          rev = "5ff183655ad98b5fc50c55c66540375bbd62438c";
          hash = "sha256-Q4v4E8Iay6rXvtUsM5ULo1cnBYduzTw42kIgJlodq5U=";
        };
      })
    ];

    # Lua config
    extraConfigLua = ''
      -- Dropbar configuration
       local dropbar = require('dropbar')
       dropbar.setup({
         bar = {
           sources = function(buf, _)
             local sources = require('dropbar.sources')
             local utils = require('dropbar.utils')

             -- Exclude NvimTree and alpha buffers
             local excluded_filetypes = { "NvimTree", "alpha", "aerial" }
             if vim.tbl_contains(excluded_filetypes, vim.bo[buf].ft) then
               return {} -- Return an empty table to disable dropbar
             end

             if vim.bo[buf].ft == 'markdown' then
               return {
                 sources.path,
                 sources.markdown,
               }
             end
             if vim.bo[buf].buftype == 'terminal' then
               return {
                 sources.terminal,
               }
             end
             return {
               sources.path,
               utils.source.fallback({
                 sources.lsp,
                 sources.treesitter,
               }),
             }
           end,
         },
       })

      -- img-clip nvim setup
      -- WARN: this config does not seem to have an effect (using keymaps instead)
      require('img-clip').setup({
        default = {
          dir_path = "images",
          relative_to_current_file = true,
        },
        filetypes = {
          quarto = {
            download_images = true,
            template = "![$CURSOR]($FILE_PATH)",
            url_encode_path = true
          }
        },
      })

      -- vague.nvim colorscheme setup
      require('vague').setup({})
      vim.cmd.colorscheme("vague")

      -- Yanking/ Pasting
      -- Preserve the contents of the default register when pasting over a selection
      vim.keymap.set("v", "p", '"_dP', { silent = true })

      -- Keymaps for navigating Toggleterm terminal windows
      vim.keymap.set('t', 'jj', [[<C-\><C-n>]])

      --- Note: I only need to esc and change windows with
      --- C-h and C-j as I only open ToggleTerm in vert and horz
      vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]])
      -- vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]])
      vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]])

      -- Special keymapings
      -- Markdown --

      -- Unordered list
      vim.keymap.set("n", "<leader>mu", "i- ", { desc = "Unordered list item", silent = true })
      vim.keymap.set("v", "<leader>mu", ":s/^/- /<CR>gv", { desc = "Unordered list item", silent = true })

      -- Ordered list
      vim.keymap.set("n", "<leader>mo", "i1. ", { desc = "Ordered list item", silent = true })
      vim.keymap.set("v", "<leader>mo", ":s/^/1. /<CR>gv", { desc = "Ordered list item", silent = true })

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

      -- Image plugin toggle function
      local image_enabled = true
      local function toggle_image_plugin()
        local image = require('image')
        if image_enabled then
          image.clear()
          image_enabled = false
          vim.notify("Image plugin disabled")
        else
          image.setup()
          image_enabled = true
          vim.notify("Image plugin enabled")
        end
      end

      -- Add a keymap to toggle the image plugin
      vim.keymap.set('n', '<leader>\\i', toggle_image_plugin, { desc = "Toggle image plugin", silent = true })
    '';
  };
}
