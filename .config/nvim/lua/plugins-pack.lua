---| Plugin Management with vim.pack ---------------------------------
-- Declares all plugins. Configuration and lazy-loading logic lives
-- in plugins-config.lua.
--
-- eager_plugins → pack/core/start/ (loaded immediately at startup)
-- opt_plugins   → pack/core/opt/   (loaded on demand via :packadd)
--
-- Themes: only the active colorscheme (from theme-config.lua) loads
-- eagerly.  Rest are opt and loaded on demand by switch_colorscheme().

--===========================================================================
--| THEME REGISTRY
--===========================================================================
-- Colorscheme name → plugin spec.  The active theme (from vim.g.active_colorscheme)
-- is placed in eager_plugins; remaining themes go to opt_plugins.

local theme_registry = {
	arthur        = { src = "https://github.com/thenewvu/vim-colors-arthur" },
	autumn        = { src = "https://github.com/wolloda/vim-autumn" },
	["black-metal"] = { src = "https://github.com/metalelf0/black-metal-theme-neovim" },
	catppuccin    = { src = "https://github.com/catppuccin/nvim",           name = "catppuccin" },
	gruvbox       = { src = "https://github.com/ellisonleao/gruvbox.nvim" },
	kanso         = { src = "https://github.com/webhooked/kanso.nvim" },
	nightfox      = { src = "https://github.com/EdenEast/nightfox.nvim" },
	onedark       = { src = "https://github.com/navarasu/onedark.nvim" },
	tokyonight    = { src = "https://github.com/folke/tokyonight.nvim" },
	vague         = { src = "https://github.com/vague2k/vague.nvim" },
	vscode        = { src = "https://github.com/Mofiqul/vscode.nvim" },
	ayu           = { src = "https://github.com/ayu-theme/ayu-vim" },
}

local active_theme = vim.g.active_colorscheme or "gruvbox"
local active_spec = theme_registry[active_theme]
if not active_spec then
	vim.notify("Unknown colorscheme '" .. active_theme .. "', falling back to gruvbox", vim.log.levels.WARN)
	active_theme = "gruvbox"
	active_spec = theme_registry.gruvbox
	vim.g.active_colorscheme = "gruvbox"
end

--===========================================================================
--| EAGER PLUGINS
--===========================================================================

local eager_plugins = {
	-- Active theme only
	active_spec,

	-- Core (must be available at startup)
	{
		src = "https://github.com/saghen/blink.cmp",
		version = "v1", -- branch
	},
	{ src = "https://github.com/brenoprata10/nvim-highlight-colors" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	{ src = "https://github.com/echasnovski/mini.icons" },
	{ src = "https://github.com/echasnovski/mini.surround" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/ggml-org/llama.vim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
	{ src = "https://github.com/moyiz/blink-emoji.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/neovim-treesitter/treesitter-parser-registry" },
	{
		src = "https://github.com/neovim-treesitter/nvim-treesitter",
		version = "main",
		dependencies = { "neovim-treesitter/treesitter-parser-registry" },
	},
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/stevearc/conform.nvim" },
}

vim.pack.add(eager_plugins, { load = true, confirm = false })

--===========================================================================
--| OPT PLUGINS (lazy-loaded via :packadd in plugins-config.lua)
--===========================================================================

local opt_plugins = {
	-- Non-active themes (loaded on demand via switch_colorscheme)
}

-- Add all non-active themes to opt
for name, spec in pairs(theme_registry) do
	if name ~= active_theme then
		table.insert(opt_plugins, spec)
	end
end

-- Other lazy plugins
local lazy_plugins = {
	{ src = "https://github.com/3rd/image.nvim" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/folke/todo-comments.nvim" },
	{ src = "https://github.com/hakonharnes/img-clip.nvim" },
	{ src = "https://github.com/hat0uma/csvview.nvim" },
	{ src = "https://github.com/jmbuhr/otter.nvim" },
	{ src = "https://github.com/jpalardy/vim-slime" },
	{ src = "https://github.com/sindrets/diffview.nvim" },
	{ src = "https://github.com/krissen/snacks-bibtex.nvim" },
	{ src = "https://github.com/nametake/golangci-lint-langserver" },
	{ src = "https://github.com/obsidian-nvim/obsidian.nvim" },
	{ src = "https://github.com/quarto-dev/quarto-nvim" },
	{ src = "https://github.com/stevearc/aerial.nvim" },
	{ src = "https://github.com/stevearc/quicker.nvim" },
}

for _, spec in ipairs(lazy_plugins) do
	table.insert(opt_plugins, spec)
end

--===========================================================================
--| DECLARED PLUGINS (for PackClean)
--===========================================================================

local function plugin_name(spec)
	if spec.name then
		return spec.name
	end
	return spec.src:match("/([^/]+)$")
end

_G.Pack_declared_plugins = {}
for _, spec in ipairs(eager_plugins) do
	_G.Pack_declared_plugins[plugin_name(spec)] = true
end
for _, spec in ipairs(opt_plugins) do
	_G.Pack_declared_plugins[plugin_name(spec)] = true
end

vim.pack.add(opt_plugins, { load = false, confirm = false })
