---| COMPLETION & SNIPPETS -----------------------------

---| Blink.cmp ----------------------------------
require("blink.cmp").setup({
	fuzzy = {
		implementation = "lua",
	},
	snippets = {
		expand = function(snippet)
			vim.snippet.expand(snippet)
		end,
	},
	completion = {
		list = {
			selection = {
				preselect = false,
				auto_insert = false,
			},
		},
		menu = {
			auto_show = true,
			auto_show_delay_ms = 1000,
			draw = {
				columns = {
					{ "kind_icon", "label", "label_description", gap = 1 },
					{ "kind", "source_name", gap = 1 },
				},
			},
		},
		documentation = { auto_show = true },
	},
	keymap = {
		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "cancel", "fallback" },
		["<CR>"] = { "select_and_accept", "fallback" },

		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },

		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback_to_mappings" },
		["<C-n>"] = { "select_next", "fallback_to_mappings" },

		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },

		["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
	},
	signature = {
		enabled = true,
		window = {
			show_documentation = true,
		},
	},
	sources = {
		default = { "path", "snippets", "lsp", "buffer" },
		per_filetype = {
			markdown = { "path", "snippets", "lsp", "emoji" },
			quarto = { "path", "snippets", "lsp", "emoji" },
		},
		providers = {
			snippets = {
				name = "snippets",
				module = "blink.cmp.sources.snippets",
				opts = {
					friendly_snippets = true,
					search_paths = { vim.fn.stdpath("config") .. "/snippets" },
				},
			},
			emoji = {
				name = "Emoji",
				module = "blink-emoji",
			},
		},
	},
	cmdline = {
		completion = {
			menu = {
				auto_show = function()
					return vim.fn.getcmdtype() == ":"
				end,
			},
		},
		keymap = {
			preset = "inherit",
		},
	},
})
