-- General plugis

-- Mini plugins ----------------------------------------------
-- Around/Inner
-- require("mini.ai").setup()
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
vim.treesitter.language.register("markdown", "quarto")

require("nvim-treesitter.configs").setup({
	highlight = { enable = false },
	indent = { enable = false },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-space>",
			node_incremental = "<C-space>",
			scope_incremental = false,
			node_decremental = "<Bs>",
		},
	},
})

-- ToggleTerm ---------------------------------------------
require("toggleterm").setup({
	open_mapping = [[<leader>tt]],
	direction = "float",
})

-- Which-key ---------------------------------------------
require("which-key").setup({
	preset = "modern",
	icons = {
		group = "",
	},
})

require("which-key").add({
	{ "<leader>a", group = "[a]i", icon = "" },
	{ "<leader>a_", hidden = true },
	{ "<leader>b", group = "[b]uffers", icon = "" },
	{ "<leader>b_", hidden = true },
	{ "<leader>c", group = "[c]ommands", icon = "" },
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
	{ "<leader>r", group = "[r]un" },
	{ "<leader>r_", hidden = true },
	{ "<leader>s", group = "[s]earch" },
	{ "<leader>s_", hidden = true },
	{ "<leader>\\", group = "[t]oggle" },
	{ "<leader>\\_", hidden = true },
})

-- Yazi ------------------------------------------------
-- require("yazi").setup({})
