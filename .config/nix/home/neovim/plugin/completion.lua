require("blink.cmp").setup({
	completion = {
		menu = {
			auto_show = false,
		},
	},
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<D-l>"] = { "select_and_accept" },
		["<D-j>"] = { "select_next", "fallback" },
		["<D-k>"] = { "select_prev", "fallback" },
		["<Enter>"] = { "select_accept_and_enter", "fallback" },
		["<D-esc>"] = { "cancel" },
		["<D-d>"] = { "scroll_documentation_down" },
		["<D-u>"] = { "scroll_documentation_up" },
		["<D-s>"] = { "show_signature" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	signature = {
		enabled = true,
		window = {
			show_documentation = false,
		},
	},
	sources = { default = { "path", "snippets", "lsp" } },
	cmdline = {
		completion = {
			menu = {
				auto_show = function(ctx)
					return vim.fn.getcmdtype() == ":"
				end,
			},
		},
		keymap = {
			preset = "inherit",
		},
	},
})

-- require("blink.compat").setup({})
