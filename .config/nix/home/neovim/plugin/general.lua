-- General plugis

-- Mini plugins ----------------------------------------------
-- Around/Inner
require("mini.ai").setup()
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
	highlight = { enable = true },
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
	open_mapping = [[<C-t>]],
	direction = "float",
})

-- Which-key ---------------------------------------------
require("which-key").setup()
require("which-key").add{
	{ "<leader>a", group = "[a]i" },
	{ "<leader>a_", hidden = true },
	{ "<leader>b", group = "[b]uffers" },
	{ "<leader>b_", hidden = true },
	{ "<leader>c", group = "[c]ommands" },
	{ "<leader>c_", hidden = true },
	{ "<leader>d", group = "[d]iagnostics" },
	{ "<leader>d_", hidden = true },
	{ "<leader>e", group = "[e]xplore" },
	{ "<leader>e_", hidden = true },
	{ "<leader>f", group = "[f]ind" },
	{ "<leader>g", group = "[g]it" },
	{ "<leader>h", group = "[h]elp" },
	{ "<leader>l", group = "[l]sp" },
	{ "<leader>m", group = "[m]arkdown" },
	{ "<leader>n", group = "[n]eo-tree" },
	{ "<leader>r", group = "[r]un" },
	{ "<leader>s", group = "[s]earch" },
	{ "<leader>w", group = "[w]orkspace" },
}
