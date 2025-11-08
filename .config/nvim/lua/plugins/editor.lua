---| Key/Event-triggered plugins -----------------------------------
-- These plugins are lazy-loaded on specific keys or events
-- lz.n will automatically merge this with other plugin specs

return {
	-- Gitsigns (load when opening files in git repos)
	{
		"gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			require("gitsigns").setup({
				word_diff = true,
			})
		end,
	},
}
