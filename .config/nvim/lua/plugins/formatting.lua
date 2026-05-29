---| CODE FORMATTING -----------------------------

---| Conform ----------------------------------------
require("conform").setup({
	default_format_ops = {
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		bash = { "shfmt" },
		json = { "jq" },
		jsonl = { "jq" },
		lua = { "stylua" },
		markdown = { "mdformat" },
		nix = { "alejandra" },
		python = { "ruff", lsp_format = "fallback" },
		quarto = { "injected" },
		r = { "air" },
		["*"] = { "trim_whitespace" },
	},
	formatters = {
		injected = {
			options = {
				ignore_errors = false,
				lang_to_ext = {
					bash = "sh",
					python = "py",
					r = "r",
					typst = "typ",
				},
			},
		},
	},
	format_on_save = function()
		-- Do not format markdown/quarto files on save
		local ft = vim.bo.filetype
		if ft == "markdown" or ft == "quarto" then
			return false
		end
		return {
			timeout_ms = 500,
			lsp_format = "fallback",
		}
	end,
	notify_on_error = false,
})
