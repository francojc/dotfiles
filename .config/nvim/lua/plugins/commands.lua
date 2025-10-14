---| Command-triggered plugins -------------------------------------
-- These plugins are lazy-loaded when specific commands are invoked
-- lz.n will automatically merge this with other plugin specs

return {
	-- Code outline
	{
		"aerial.nvim",
		cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialPrev", "AerialNext" },
		after = function()
			require("aerial").setup({
				on_attach = function(bufnr)
					-- Jump forwards/backwards with '{' and '}'
					vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
					vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
				end,
			})
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

	-- LazyGit
	{
		"lazygit.nvim",
		cmd = { "LazyGit", "LazyGitLog" },
		-- No setup needed for lazygit.nvim
	},

	-- Todo comments
	{
		"todo-comments.nvim",
		cmd = { "TodoFzfLua", "TodoTelescope", "TodoTrouble", "TodoQuickFix", "TodoLocList" },
		event = { "BufReadPost", "BufNewFile" },
		after = function()
			require("todo-comments").setup({
				-- Explicit labels and their colors
				keywords = {
					FIX = { color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
					TODO = { color = "info", alt = { "NOTE" } },
					WARN = { color = "warning", alt = { "WARNING", "XXX" } },
				},
				-- Inline highlighting behavior
				highlight = {
					before = "",
					after = "fg",
					keyword = "wide",
					comments_only = true,
					multiline = false,
				},
			})
		end,
	},
	-- Terminal
	{
		"toggleterm.nvim",
		cmd = "ToggleTerm",
		after = function()
			require("toggleterm").setup({})
		end,
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
