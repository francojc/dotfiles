{
  pkgs,
  ...
}: {
  imports = [
    # ./alpha.nix
    # ./bufferline.nix
    # ./lspsaga.nix
    # ./lualine.nix
    # ./obsidian.nix
    # ./slime.nix
    # ./snacks.nix
    ./treesitter.nix
    ./which-key.nix
  ];
  programs.nixvim = {
    plugins = {
      aerial.enable = false;
      auto-session = {
        enable = true;
        settings = {
          bypass_save_filetypes = ["alpha" "NvimTree" "term"];
        };
      };
      codecompanion = {
        enable = true;
      };
      conform-nvim = {
        enable = false;
        settings = {
          default_format_opts = {
            lsp_format = "last"; 
          };
          formatters = {}; 
          formatters_by_ft = {
            python = [ "black" "isort" ];
            nix = [ "alejandra" ];
            r = [ "styler" ];
            "*" = ["trim_whitespace" "squeeze_blanks"];
          };
        };
      };
      copilot-vim = {
        enable = false;
        # Consider managing node via Nix instead of hardcoding brew path
        settings.node_command = "/opt/homebrew/bin/node";
      };
      copilot-chat = {
        enable = false;
        settings = {
          answer_header = "  ";
          error_header = "  ";
          question_header = "  ";
          separator = "───";
          model = "claude-3.7-sonnet";
          temperature = 0.2;
        };
      };
      diffview.enable = false;
      fidget.enable = false;
      flash.enable = false;
      fzf-lua = {
        enable = true;
        profile = "fzf-native";
        settings = {
          oldfiles = {
            cwd_only = true;
          };
        };
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
      grug-far.enable = false;
      image = {
        enable = false;
        settings = {
          editor_only_render_when_focused = true;
          integrations = {
            markdown = {
              filetypes = ["markdown" "quarto" "rmd"];
            };
          };
          max_height_window_percentage = 30;
          window_overlap_clear_enabled = true;
        };
      };
      lazygit.enable = false;
      mini = {
        enable = false;
        modules = {
          indentscope = {};
          icons = {};
          pairs = {};
          surround = {};
        };
      };
      nix.enable = false;
      notify.enable = false;
      colorizer = {
        enable = false;
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
        enable = false;
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
      otter.enable = false;
      quarto.enable = false;
      render-markdown = {
        enable = false;
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
          file_types = ["markdown" "quarto" "rmd" "Avante"];
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

      todo-comments.enable = false;

      toggleterm = {
        enable = false;
        settings = {
          auto_scroll = true;
          direction = "horizontal";
          open_mapping = "[[<C-t>]]";
          size = 15;
        };
      };

      trouble.enable = false;
      web-devicons.enable = false;
      yazi.enable = false;
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
          vim.opt_local.spelllang = "en_us" -- Default if file doesn't exist
        end
      end

      local function set_spell_lang(lang)
        local project_root = get_project_root()
        if not project_root then
          vim.notify("Could not determine project root to save spell language.", vim.log.levels.WARN)
          return
        end
        local spell_lang_file = project_root .. "/.nvim_spell_lang"
        vim.fn.writefile({lang}, spell_lang_file)
        vim.opt_local.spelllang = lang
        vim.notify("Set spell language to: " .. lang .. " for project " .. project_root)
      end

      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("UserSpellLang", { clear = true }),
        pattern = "*",
        callback = function()
          -- Defer loading slightly to ensure filetype is set
          vim.schedule(load_spell_lang)
        end,
      })

      vim.api.nvim_create_user_command("SpellLang", function()
        vim.ui.select(
          { "en_us", "es" }, -- Add more languages as needed
          {
            prompt = "Select spell language for this project:",
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
        local image_status, image = pcall(require, 'image')
        if not image_status then
          vim.notify("image.nvim plugin not available", vim.log.levels.WARN)
          return
        end

        if image_enabled then
          image.clear()
          -- You might need a more specific way to disable it if setup() isn't the only enabler
          image_enabled = false
          vim.notify("Image plugin rendering disabled")
        else
          -- Re-running setup might not be the intended way to re-enable rendering.
          -- Check image.nvim docs for the correct way to toggle rendering on/off.
          -- For now, just setting the flag and notifying.
          -- image.setup() -- This might re-apply the full config, maybe not desired.
          image_enabled = true
          vim.notify("Image plugin rendering enabled (may require buffer reload)")
        end
      end

      -- Add a keymap to toggle the image plugin
      vim.keymap.set('n', '<leader>\\i', toggle_image_plugin, { desc = "Toggle image plugin rendering", silent = true })
    '';
  };
}
