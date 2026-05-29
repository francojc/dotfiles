---| EDITOR ENHANCEMENTS -----------------------------

---| Gitsigns ----------------------------------
require("gitsigns").setup({
	word_diff = false,
})

---| Mini Modules ----------------------------------
require("mini.icons").setup({})
require("mini.surround").setup({
	custom_surroundings = {
		h = {
			-- Add:       sa h  (then motion)
			-- Replace:   sr h
			-- Delete:    sd h
			output = function()
				return { left = "==", right = "==" }
			end,
		},
	},
})

---| Lualine ----------------------------------
require("lualine").setup({
	options = {
		theme = "auto",
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		globalstatus = false,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { { "filename", path = 1 } }, -- relative path
		lualine_x = {
			{
				function()
					return vim.g.llama_status or ""
				end,
				color = { fg = "#918374" },
			},
			"filetype",
		},
		lualine_y = { "searchcount", "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "location" },
	},
})

---| Snacks ----------------------------------
require("snacks").setup({
	bigfile = { enabled = false },
	dashboard = {
		enabled = true,
		sections = {
			{ section = "header" },
			-- { section = "keys", gap = 1, padding = 1 },
		},
	},
	explorer = { enabled = false }, -- Using yazi
	git = { enabled = false },
	gitbrowse = { enabled = false },
	image = { enabled = false }, -- Using image.nvim
	input = { enabled = false },
	notifier = { enabled = false }, -- Using standard vim.notify
	picker = {
		enabled = true,
		formatters = {
			file = {
				filename_first = true,
			},
		},
		layout = {},
	},
	quickfile = { enabled = false },
	scope = { enabled = false },
	scroll = { enabled = false },
	gh = {
		enabled = true,
		win = {
			zindex = 50,
			style = "minimal",
		},
	},
	statuscolumn = { enabled = false },
	terminal = { enabled = false },
	toggle = { enabled = true }, -- Complements toggle functions
	words = { enabled = false },
})

-- Register Snacks picker as the vim.ui.select backend
vim.ui.select = Snacks.picker.ui_select

---| WhichKey ----------------------------------
require("which-key").setup({
	preset = "helix",
	delay = 2000,
	icons = {
		group = "",
	},
	plugins = {
		marks = true,
		registers = true,
	},
})

-- Add keymap groups
local wk = require("which-key")
wk.add({
	{ "<leader>b", group = "Buffer", icon = "󰓩 " },
	{ "<leader>c", group = "Code", icon = "󰌗" },
	{ "<leader>d", group = "Diagnostics/Debug", icon = "󰒡" },
	{ "<leader>e", group = "Explore", icon = "󰥩" },
	{ "<leader>f", group = "Files", icon = "󰈔" },
	{ "<leader>g", group = "Git", icon = "󰊢" },
	{ "<leader>gi", group = "GitHub issues", icon = "󰌚" },
	{ "<leader>h", group = "Help", icon = "󰋗" },
	{ "<leader>l", group = "LSP", icon = "󰅩" },
	{ "<leader>lc", group = "Call Hierarchy", icon = "󰘦" },
	{ "<leader>m", group = "Markdown", icon = "󰉫" },
	{ "<leader>o", group = "Obsidian", icon = "󱞁" },
	{ "<leader>q", group = "Quarto", icon = "󰠮" },
	{ "<leader>r", group = "References", icon = "󰒋" },
	{ "<leader>rb", desc = "BibTeX citations" },
	{ "<leader>s", group = "Search", icon = "󰢶" },
	{ "<leader>t", group = "Toggle", icon = "󰔡" },
	{ "<leader>u", group = "Update/Plugins", icon = "󰚰 " },
	{ "<leader>w", proxy = "<C-w>", group = "Windows", icon = "󰪷" },
	{ "<leader>x", desc = "Quit", icon = "󰗼" },
})

---| Treesitter ----------------------------------
require("nvim-treesitter").setup()

vim.api.nvim_create_autocmd("FileType", {
	group = "personal",
	callback = function()
		local ok = pcall(vim.treesitter.start)
		if not ok then
			vim.bo.syntax = "on" -- fallback to regex syntax
		end
	end,
})

---| Highlight Colors ----------------------------------
require("nvim-highlight-colors").setup({})

---| Yazi ----------------------------------
-- Disable netrw so yazi takes over directory browsing
vim.g.loaded_netrwPlugin = 1
require("yazi").setup({
	open_for_directories = true,
	floating_window_scaling_factor = 0.95,
	yazi_floating_window_border = "single",
})
