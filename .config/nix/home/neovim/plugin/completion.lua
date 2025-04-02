require("blink.cmp").setup({
	appearance = { use_nvim_cmp_as_default = true },
	completion = {
		accept = { auto_brackets = { enabled = true } },
		menu = { auto_show = false },
		documentation = { auto_show = true },
	},
	keymap = { preset = "enter" },
	signature = { enabled = true },
	snippets = { preset = "luasnip" },
	sources = { default = { "path", "snippets", "lsp" } },
})
