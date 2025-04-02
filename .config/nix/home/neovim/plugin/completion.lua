require("blink.cmp").setup({
	appearance = {
		use_nvim_cmp_as_default = true,
	},
	completion = {
		accept = { auto_brackets = { enabled = true } },
		menu = {
			auto_show = false,
		},
		documentation = {
			auto_show = true,
		},
	},
	keymap = {
		preset = "enter",
	},
	sources = {
		default = { "path", "snippets", "lsp" },
		snippets = { preset = "luasnip" },
		signature = { enabled = true },
	},
})
