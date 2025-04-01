-- Copilot (copilot-lua)
require("copilot").setup({
  panel = {
    enabled = false,
    auto_refresh = true,
    layout = {
      position = "bottom",
      ratio = 0.2,
    },
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 75,
    keymap = {
      accept = "<Tab>",
      accept_word = "<C-d>",
      accept_line = "<C-f>",
      next = "<C-n>",
      prev = "<C-p>",
      dismiss = "<C-e>",
    },
  },
  filetypes = {
    yaml = true,
    markdown = true,
    quarto = true,
    nix = true,
    ["*"] = false,
  },
})

-- CodeCompanion (codecompanion-nvim)
