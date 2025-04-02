require("blink.cmp").setup({
	appearance = {
		use_nvim_cmp_as_default = true,
	},
	completion = {
		accept = { auto_brackets = { enabled = true } },
	},
	keymap = {
		preset = "enter",
	},
	sources = {
		default = { "path", "snippets", "lsp" },
	},
})
