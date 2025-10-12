---| Filetype-triggered plugins -----------------------------------
-- These plugins are lazy-loaded when specific filetypes are opened
-- lz.n will automatically merge this with other plugin specs

return {
  -- Markdown/Quarto plugins
  {
    "obsidian.nvim",
    ft = "markdown",
    after = function()
      -- Only setup if not already configured
      if not vim.g.obsidian_setup_done then
        require("obsidian").setup({
          legacy_commands = false,
          ui = {
            enable = false,
          },
          workspaces = {
            {
              name = "Notes",
              path = "~/Obsidian/Notes/",
            },
            {
              name = "Personal",
              path = "~/Obsidian/Personal/",
            },
          },
          daily_notes = {
            folder = "Daily",
            template = "Assets/Templates/Daily.md",
          },
          templates = {
            folder = "Assets/Templates",
          },
          new_notes_location = "Inbox",
          picker = {
            name = "fzf-lua",
          },
          attachments = {
            img_folder = "Assets/Attachments",
          },
          completion = {
            nvim_cmp = false,
            blink = true,
          },
        })
        vim.g.obsidian_setup_done = true
      end
    end,
  },

  {
    "render-markdown.nvim",
    ft = { "markdown", "quarto" },
    after = function()
      require("render-markdown").setup({
        latex = { enabled = false },
        bullet = {
          icons = { "■ ", "□ ", "▪ ", "▫ " },
          left_pad = 0,
          right_pad = 2,
        },
        checkbox = {
          unchecked = { icon = "□ ", highlight = "RenderMarkdownUnchecked" },
          checked = { icon = " ", highlight = "RenderMarkdownChecked" },
          custom = {
            todo = { raw = "[-]", rendered = " ", highlight = "DiagnosticInfo", scope_highlight = nil },
            forward = { raw = "[>]", rendered = " ", highlight = "DiagnosticError", scope_highlight = nil },
            important = { raw = "[!]", rendered = " ", highlight = "DiagnosticWarn", scope_highlight = nil },
          },
        },
        code = {
          language_icon = false,
          width = "block",
          min_width = 80,
        },
        completions = { lsp = { enabled = true } },
        dash = { enabled = false },
        file_types = { "markdown", "quarto" },
        heading = {
          backgrounds = {},
          left_pad = 0,
          position = "inline",
          right_pad = 3,
          icons = {
            "# ",
            "## ",
            "### ",
            "#### ",
            "##### ",
            "###### ",
          },
        },
        html = {
          enabled = true,
          comment = { conceal = false },
        },
        pipe_table = {
          preset = "round",
        },
      })
    end,
  },

  {
    "image.nvim",
    ft = { "markdown", "quarto" },
    after = function()
      require("image").setup({
        processor = "magick_cli",
        integrations = {
          markdown = {
            clear_in_insert_mode = false,
            filetypes = { "markdown", "quarto" },
            only_render_image_at_cursor = false,
          },
        },
      })
    end,
  },

  {
    "img-clip.nvim",
    ft = { "markdown", "quarto" },
    after = function()
      require("img-clip").setup({
        default = {
          dir_path = "./images",
          relative_to_current_file = true,
          show_dir_path_in_prompt = true,
        },
      })
    end,
  },

  -- Quarto-specific plugins
  {
    "quarto-nvim",
    ft = "quarto",
    after = function()
      if not vim.g.quarto_setup_done then
        require("quarto").setup({
          lspFeatures = {
            enabled = true,
            chunks = "curly",
            languages = { "r", "python", "julia", "bash", "html" },
            diagnostics = {
              enabled = true,
              triggers = { "BufWritePost" },
            },
            completion = {
              enabled = true,
            },
          },
          codeRunner = {
            enabled = true,
            default_method = "slime",
            never_run = { "yaml" },
          },
          keymap = false,
        })
        vim.g.quarto_setup_done = true
      end
    end,
  },

  {
    "otter.nvim",
    ft = "quarto",
    after = function()
      if not vim.g.otter_setup_done then
        require("otter").setup({
          lsp = {
            diagnostic_update_events = { "BufWritePost" },
            root_dir = function(_, bufnr)
              return vim.fs.root(bufnr or 0, {
                ".git",
                "_quarto.yml",
                "DESCRIPTION",
              }) or vim.fn.getcwd(0)
            end,
          },
          buffers = {
            set_filetype = true,
            write_to_disk = false,
          },
          handle_leading_whitespace = true,
        })
        vim.g.otter_setup_done = true
      end
    end,
  },

  -- CSV viewer
  {
    "csvview.nvim",
    ft = "csv",
    after = function()
      require("csvview").setup({})
    end,
  },
}
