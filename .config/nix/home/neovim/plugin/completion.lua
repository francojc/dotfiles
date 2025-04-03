require("blink.cmp").setup({
	completion = {
		accept = { auto_brackets = { enabled = true } },
		menu = { auto_show = true },
		documentation = { auto_show = true },
	},
	keymap = { preset = "enter" },
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
		-- providers = {
		-- 	snippets = {
		-- 		opts = { search_paths = os.getenv("HOME") .. "/.config/nix/home/neovim/snippets" },
		-- 	},
		-- },
	},
})
