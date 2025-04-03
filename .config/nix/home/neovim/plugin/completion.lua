require("blink.cmp").setup({
	completion = {
		menu = { auto_show = true },
		documentation = { auto_show = true, auto_show_delay_ms = 500 },
	},
	keymap = { preset = "enter" },
	snippets = {},
	sources = { default = { "path", "snippets", "lsp" } },
})
