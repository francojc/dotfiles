---| PLUGINS CONFIGURATION -----------------------------
-- Eager plugin setup, split by domain.
-- Each module is loaded once at startup.

require("plugins.completion")
require("plugins.themes")
require("plugins.formatting")
require("plugins.lsp")
require("plugins.editor")
require("plugins.lazy")
