-- UI config

-- Alpha
require('alpha').setup(require('alpha.themes.startify').config)

-- Bufferline
require('bufferline').setup({})

-- Lualine
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = ' ', right = ' '}, 
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = { "neo-tree", "toggleterm", "alpha" },
      winbar = { "alpha" },
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'lsp_progress', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

-- Render Markdown
require('render-markdown').setup({
  completions = { blink = { enabled = true } },
})
-- Render Markdown
require('render-markdown').setup({
  completions = { blink = { enabled = true } },
})

