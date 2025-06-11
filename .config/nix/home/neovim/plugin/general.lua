-- General plugins

-- Auto session ---------------------------------------------
require("auto-session").setup({
	auto_restore = false,
	bypass_save_filetypes = { "alpha", "dashboard", "neo-tree" },
})

-- Fzf-Lua ---------------------------------------------------
require("fzf-lua").setup({
	"hide",
	file_icon_padding = " ",
})

-- Mini plugins ----------------------------------------------
-- Surround
require("mini.surround").setup()
-- Indentscope
require("mini.indentscope").setup()
-- Icons
require("mini.icons").setup()
-- Open-close chars
require("mini.pairs").setup()

-- Neotree
require("neo-tree").setup({
	close_if_last_window = true,
})

-- Treesitter -----------------------------------------------
-- Make treesitter Quarto support work with markdown
vim.treesitter.language.register("markdown", "quarto", "codecompanion")

-- Setup
require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<Enter>",
			node_incremental = "<Enter>",
			scope_incremental = false,
			node_decremental = "<Backspace>",
		},
	},
	indent = { enable = false },
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = { query = "@function.outer", desc = "Select outer function" },
				["if"] = { query = "@function.inner", desc = "Select inner function" },
				["ac"] = { query = "@comment.outer", desc = "Select outer comment" },
				["ic"] = { query = "@comment.inner", desc = "Select inner comment" },
			},
			include_surrounding_whitespace = true,
		},
	},
})

-- ToggleTerm ---------------------------------------------
require("toggleterm").setup({})

-- Which-key ---------------------------------------------
require("which-key").setup({
	preset = "helix",
	icons = {
		group = " ",
	},
	win = {
		border = "rounded",
		title = false,
	},
})

require("which-key").add({
	{ "<leader>a", group = "[a]i" },
	{ "<leader>a_", hidden = true },
	{ "<leader>b", group = "[b]uffers" },
	{ "<leader>b_", hidden = true },
	{ "<leader>c", group = "[c]ode" },
	{ "<leader>c_", hidden = true },
	{ "<leader>d", group = "[d]iagnostics" },
	{ "<leader>d_", hidden = true },
	{ "<leader>e", group = "[e]xplore" },
	{ "<leader>e_", hidden = true },
	{ "<leader>f", group = "[f]ind" },
	{ "<leader>f_", hidden = true },
	{ "<leader>g", group = "[g]it" },
	{ "<leader>g_", hidden = true },
	{ "<leader>h", group = "[h]elp" },
	{ "<leader>h_", hidden = true },
	{ "<leader>l", group = "[l]sp" },
	{ "<leader>l_", hidden = true },
	{ "<leader>m", group = "[m]arkdown" },
	{ "<leader>m_", hidden = true },
	{ "<leader>o", group = "[o]bsidian" },
	{ "<leader>o_", hidden = true },
	{ "<leader>q", group = "[q]uarto" },
	{ "<leader>q_", hidden = true },
	{ "<leader>r", group = "[r]un" },
	{ "<leader>r_", hidden = true },
	{ "<leader>s", group = "[s]earch" },
	{ "<leader>s_", hidden = true },
	{ "<leader>\\", group = "[t]oggle" },
	{ "<leader>\\_", hidden = true },
})

-- Yazi ------------------------------------------------
require("yazi").setup({})
