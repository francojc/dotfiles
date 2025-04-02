require("blink.cmp").setup({
	appearance = { use_nvim_cmp_as_default = true },
	completion = {
		accept = { auto_brackets = { enabled = true } },
		menu = { auto_show = false },
		documentation = { auto_show = true },
	},
	keymap = { preset = "enter" },
	signature = { enabled = true },
	snippets = {
		preset = "luasnip",
		expand = function(snippet)
			vim.snippet.lsp_expand(snippet)
		end,
		active = function(filter)
			return vim.snippet.active(filter)
		end,
		jump = function(direction)
			return vim.snippet.jump(direction)
		end,
	},
	sources = {
		default = { "path", "snippets", "lsp" },
		providers = {
			snippets = {
				opts = { search_paths = os.getenv("HOME") .. "/.config/nix/home/neovim/snippets" },
			},
		},
	},
})
