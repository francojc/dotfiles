-- Description: UI plugins, like statusline, filetree, etc.
return {
  -- telescope
  -- a nice seletion UI also to find and open files
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-dap.nvim" },
      -- {
      --   "jmbuhr/telescope-zotero.nvim",
      --   enabled = true,
      --   dev = false,
      --   dependencies = {
      --     { "kkharji/sqlite.lua" },
      --   },
      --   config = function()
      --     vim.keymap.set("n", "<leader>fz", ":Telescope zotero<cr>", { desc = "[z]otero" })
      --   end,
      -- },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local previewers = require("telescope.previewers")
      local new_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        filepath = vim.fn.expand(filepath)
        vim.loop.fs_stat(filepath, function(_, stat)
          if not stat then
            return
          end
          if stat.size > 100000 then
            return
          else
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
          end
        end)
      end

      local telescope_config = require("telescope.config")
      -- Clone the default Telescope configuration
      local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }
      -- I don't want to search in the `docs` directory (rendered quarto output).
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!docs/*")

      telescope.setup({
        defaults = {
          buffer_previewer_maker = new_maker,
          vimgrep_arguments = vimgrep_arguments,
          file_ignore_patterns = {
            "node_modules",
            "%_cache",
            ".git/",
            "site_libs",
            ".venv",
          },
          layout_strategy = "vertical",
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "bottom",
            width = 0.95,
          },
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = false,
              ["<esc>"] = actions.close,
              ["<c-j>"] = actions.move_selection_next,
              ["<c-k>"] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = false,
            find_command = {
              "rg",
              "--files",
              "--hidden",
              "--glob",
              "!.git/*",
              "--glob",
              "!**/.Rpro.user/*",
              "--glob",
              "!_site/*",
              "--glob",
              "!docs/**/*.html",
              "-L",
            },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
      telescope.load_extension("dap")
      -- telescope.load_extension("zotero")
    end,
  },

  { -- Highlight todo, notes, etc in comments
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },

  { -- edit the file system as a buffer
    "stevearc/oil.nvim",
    enable = false,
    opts = {
      keymaps = {
        ["<C-s>"] = false,
        ["<C-h>"] = false,
        ["<C-l>"] = false,
      },
      view_options = {
        show_hidden = true,
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
  },

  { -- bufferline
    'akinsho/bufferline.nvim',
    enable = true,
    version = "*", 
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
  },

  { -- statusline
    "nvim-lualine/lualine.nvim",
    enabled = true,
    config = function()
      local function macro_recording()
        local reg = vim.fn.reg_recording()
        if reg == "" then
          return ""
        end
        return "📷[" .. reg .. "]"
      end

      ---@diagnostic disable-next-line: undefined-field
      require("lualine").setup({
        options = {
          fmt = string.lower,
          theme = "gruvbox",
          icons_enabled = true,
          section_separators = { left = "", right = "" },
          component_separators = { left = "|", right = "|" },
          globalstatus = true,
        },
        sections  = {
          lualine_a = { "mode", macro_recording },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            {
              "filename",
              path = 4,
              file_status = true,
              symbols = {
                modified = "",
                readonly = "",
                unnamed = "",
                newfile = "",
              },
            },
          },
          lualine_x = {
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        tabline = {
          lualine_a = {
            'windows',
          },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
        },
      })
    end,
  },

  { -- scrollbar
    "dstein64/nvim-scrollview",
    enabled = true,
    opts = {
      current_only = true,
    },
  },

  { -- highlight occurences of current word
    "RRethy/vim-illuminate",
    enabled = false,
  },

  -- filetree
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<space>ee", ":Neotree toggle<cr>", desc = "toggle nvim-tree" },
    },
  },

  -- file manager
  {
    "mikavilpas/yazi.nvim",
    enable = true,
    event = "VeryLazy",
    keys = {
      {
        "<leader>yy",
        function()
          require("yazi").yazi()
        end,
        desc = "Open yazi file manager",
      },
      {
        -- Open in the current working directory
        "<leader>yw",
        function()
          require("yazi").yazi(nil, vim.fn.getcwd())
        end,
        desc = "Open the file manager in nvim's working directory",
      },
    },
    opts = {
      open_for_directories = true,
    },
  },

  -- show keybinding help window
  {
    "folke/which-key.nvim",
    enabled = true,
    config = function()
      require("which-key").setup({
        -- types: 'classic', 'modern, 'helix'
        preset = "modern",
      })
      require("config.keymap")
    end,
  },

  { -- show tree of symbols in the current file
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = {
      { "<leader>lo", ":SymbolsOutline<cr>", desc = "symbols outline" },
    },
    opts = {},
  },

  { -- or show symbols in the current file as breadcrumbs
    -- WARN: this plugin is enabled, but does not show as it is masked
    -- by the `lualine` statusline in the tabline position
    -- It does, however, mask the annoying file path that started showing
    -- up below the statusline. 07/19/2024
    "Bekaboo/dropbar.nvim",
    enabled = true,
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    config = function()
      -- turn off global option for windowline
      vim.opt.winbar = nil
      vim.keymap.set("n", "<leader>ls", require("dropbar.api").pick, { desc = "[s]ymbols" })
    end,
  },

  { -- terminal
    "akinsho/toggleterm.nvim",
    opts = {
      open_mapping = [[<c-\>]],
      direction = "float",
    },
  },

  -- UI enhancements
  {
    "folke/noice.nvim",
    enabled = true,
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        cmdline = {
          enabled = true,
        },
        messages = {
          enabled = true,
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
        routes = {
          {
            filter = { warning = true },
            opts = { skip = true },
          }
        },
        extensions = {
          "fzf",
          "telescope",
          -- "zotero",
          "aerial",
        },
      })
    end,
  },

  { -- show diagnostics list
    "folke/trouble.nvim",
    enabled = false,
    config = function()
      local trouble = require("trouble")
      trouble.setup({})
      local function goto_next()
        trouble.next({ skip_groups = true, jump = true })
      end
      local function goto_previous()
        trouble.previous({ skip_groups = true, jump = true })
      end
      vim.keymap.set("n", "]t", goto_next, { desc = "next [t]rouble item" })
      vim.keymap.set("n", "[t", goto_previous, { desc = "previous [t]rouble item" })
    end,
  },

  { -- show indent lines
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
    main = "ibl",
    opts = {
      indent = { char = "│" },
    },
  },

  { -- highlight markdown headings and code blocks etc.
    "lukas-reineke/headlines.nvim",
    enabled = false,
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("headlines").setup({
        quarto = {
          query = vim.treesitter.query.parse(
            "markdown",
            [[
                (fenced_code_block) @codeblock
                ]]
          ),
          codeblock_highlight = "CodeBlock",
          treesitter_language = "markdown",
        },
        markdown = {
          query = vim.treesitter.query.parse(
            "markdown",
            [[
                (fenced_code_block) @codeblock
                ]]
          ),
          codeblock_highlight = "CodeBlock",
        },
      })
    end,
  },

  { -- Aerial: outline window
    "stevearc/aerial.nvim",
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
  {
    "mrjones2014/smart-splits.nvim",
  },
}
