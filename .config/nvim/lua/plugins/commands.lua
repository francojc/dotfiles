---| Command-triggered plugins -------------------------------------
-- These plugins are lazy-loaded when specific commands are invoked
-- lz.n will automatically merge this with other plugin specs

return {
	-- CSV toggle
	{
		"csvview.nvim",
		cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
		after = function()
			require("csvview").setup({})
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
