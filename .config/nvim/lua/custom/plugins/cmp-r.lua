return {
  'R-nvim/cmp-r',
  config = function()
    local cmpr = require 'cmp_r'

    cmpr.setup {
      filetypes = { 'r', 'rmd', 'quarto', 'rhelp' },
      doc_width = 80,
      quarto_intel = '/Applications/quarto/share/editor/tools/yaml/yaml-intelligence-resources.json',
    }
  end,
}
