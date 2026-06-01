---| COMPLETION & SNIPPETS -----------------------------

---| Blink.cmp ----------------------------------
local function native_pum_key(key)
	return function(cmp)
		if vim.fn.pumvisible() == 1 and not cmp.is_menu_visible() then
			return vim.api.nvim_replace_termcodes(key, true, true, true)
		end
	end
end

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
		preset = "none",

		["<C-space>"] = { "show" },
		["<C-e>"] = { "cancel", "fallback" },
		["<CR>"] = { native_pum_key("<C-y>"), "select_and_accept", "fallback" },

		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },

		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-p>"] = { native_pum_key("<C-p>"), "select_prev" },
		["<C-n>"] = { native_pum_key("<C-n>"), "select_next" },
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
