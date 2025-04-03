require("blink.cmp").setup({
	completion = {
		accept = { auto_brackets = { enabled = true } },
		menu = {
			auto_show = true,
			draw = {
				columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
			},
		},
		documentation = { auto_show = true, auto_show_delay_ms = 500 },
	},
	keymap = { preset = "enter" },
	snippets = {
		preset = "luasnip",
	},
	sources = {
		default = { "path", "snippets", "lsp" },
		-- providers = {
		-- 	snippets = {
		-- 		opts = { search_paths = os.getenv("HOME") .. "/.config/nix/home/neovim/snippets" },
		-- 	},
		-- },
	},
})
