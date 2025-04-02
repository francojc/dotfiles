require("blink.cmp").setup({
	appearance = {
		use_nvim_cmp_as_default = true,
	},
	completion = {
		accept = { auto_brackets = { enabled = true } },
	},
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show" },
		["<C-e>"] = { "hide" },
		["<C-y>"] = { "accept_and_enter" },
		["<Tab>"] = { "select_next" },
		["<S-Tab>"] = { "select_prev" },
		["<C-u>"] = { "scroll_documentation_up" },
		["<C-d>"] = { "scroll_documentation_down" },
	},
	sources = {
		default = { "path", "snippets", "lsp" },
	},
})
