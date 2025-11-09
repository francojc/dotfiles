---| Command-triggered plugins -------------------------------------
-- These plugins are lazy-loaded when specific commands are invoked
-- lz.n will automatically merge this with other plugin specs

return {
	-- Aerial toggle
	{
		"aerial.nvim",
		cmd = { "AerialToggle", "AerialOpen", "AerialClose" },
		after = function()
			require("aerial").setup({})
		end,
	},

	-- CSV toggle
	{
		"csvview.nvim",
		cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
		after = function()
			require("csvview").setup({})
		end,
	},

	-- Highlight Colors
	{
		"nvim-highlight-colors",
		cmd = { "HighlightColors" },
		after = function()
			require("nvim-highlight-colors").setup({})
		end,
	},

	-- LazyGit
	{
		"lazygit.nvim",
		cmd = { "LazyGit", "LazyGitLog" },
		-- No setup needed for lazygit.nvim
	},

	-- Yazi file manager
	{
		"yazi.nvim",
		cmd = "Yazi",
		after = function()
			require("yazi").setup({})
		end,
	},
}
