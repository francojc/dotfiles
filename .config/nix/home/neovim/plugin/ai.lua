-- Copilot (copilot-lua)

-- CodeCompanion (codecompanion-nvim)
require("codecompanion").setup({
	display = {
		action_palette = {
			provider = "fzf_lua",
		},
	},
	strategies = {
		chat = {
			adapter = "copilot",
		},
	},
})
