-- CodeCompanion (codecompanion-nvim)
require("codecompanion").setup({
	adapters = {
		-- Use sonnet with Copilot
		copilot = function()
			return require("codecompanion.adapters").extend("copilot", {
				schema = {
					model = {
						default = "claude-3.7-sonnet",
						choices = {
							["o3-mini-2025-01-31"] = { opts = { can_reason = true } },
							"gpt-4o-2024-08-06",
						},
					},
				},
			})
		end,
		-- Use gemini-2.5-pro-exp-03-25 with Gemini
		gemini = function()
			return require("codecompanion.adapters").extend("gemini", {
				schema = {
					model = { default = "gemini-2.5-pro-exp-03-25" },
				},
			})
		end,
	},
	strategies = {
		chat = {
			adapter = "copilot",
			roles = {
				---@type string|fun(adapter: CodeCompanion.Adapter): string
				llm = function(adapter)
					return " (" .. adapter.formatted_name .. ") "
				end,

				---@type string
				user = " -------------",
			},
		},
	},
})
