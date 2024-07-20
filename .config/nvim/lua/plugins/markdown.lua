return {
  "MeanderingProgrammer/markdown.nvim",
  enabled = true,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("render-markdown").setup({
      file_types = { "markdown", "quarto", "rmarkdown" },
      bullet = {
        icons = { "▪", "▫", "▪", "▫", "▸", "▹", "•", "◦" },
      },
    })
  end,
}
