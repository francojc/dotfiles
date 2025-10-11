-- Custom highlights for Sidekick NES to look like Copilot ghost text
-- This file customizes the Next Edit Suggestions appearance to use foreground colors only
--
-- Features:
-- - Ghost text appearance similar to Copilot suggestions
-- - Foreground-only styling (no background blocks)
-- - Gruvbox-compatible colors
-- - Italic styling for better visual distinction
-- - Automatic re-application when colorscheme changes

local M = {}

-- Gruvbox-inspired colors that work well with ghost text appearance
local colors = {
  ghost_text = "#928374",  -- Muted gray (similar to CopilotSuggestion #808080)
  addition = "#8ec07c",     -- Soft green for additions
  context = "#928374",      -- Gray for context lines
  sign = "#d3869b",         -- Soft purple for signs
}

function M.setup()
  -- Custom highlight group for NES suggestions (ghost text effect)
  vim.api.nvim_set_hl(0, "SidekickNESuggestion", {
    fg = colors.ghost_text,
    ctermfg = 245,
    italic = true,
    default = true,
  })

  -- Customize existing Sidekick highlight groups for better visual consistency
  vim.api.nvim_set_hl(0, "SidekickDiffAdd", {
    fg = colors.addition,
    ctermfg = 108,
    italic = true,
    default = true,
  })

  vim.api.nvim_set_hl(0, "SidekickDiffContext", {
    fg = colors.context,
    ctermfg = 245,
    italic = true,
    default = true,
  })

  vim.api.nvim_set_hl(0, "SidekickSign", {
    fg = colors.sign,
    ctermfg = 175,
    default = true,
  })

  -- Ensure Copilot suggestions remain consistent
  vim.api.nvim_set_hl(0, "CopilotSuggestion", {
    fg = colors.ghost_text,
    ctermfg = 245,
    italic = true,
    default = true,
  })
end

-- Autocommand to apply highlights when colorscheme loads
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    M.setup()
  end,
})

-- Additional autocommands to ensure highlights persist
local augroup = vim.api.nvim_create_augroup("SidekickHighlights", { clear = true })

-- Re-apply highlights when sidekick initializes
vim.api.nvim_create_autocmd("User", {
  pattern = "SidekickReady",
  group = augroup,
  callback = function()
    M.setup()
  end,
})

-- Re-apply highlights when entering a buffer (in case highlights are lost)
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  callback = function()
    -- Only apply if sidekick is available
    if package.loaded["sidekick"] then
      vim.defer_fn(function()
        M.setup()
      end, 100)
    end
  end,
})

return M