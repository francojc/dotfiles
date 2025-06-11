-- Tools config file

-- Obsidian ------------------------------------------------------------------
require("obsidian").setup({
	ui = { enable = false },
	workspaces = {
		{
			name = "Notes",
			path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes/",
		},
		{
			name = "Personal",
			path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal/",
		},
	},
	daily_notes = {
		folder = "Daily",
		template = "Assets/Templates/Daily.md",
	},
	templates = {
		folder = "Assets/Templates",
	},
	new_notes_location = "Inbox",
	picker = {
		name = "fzf-lua",
	},
	attachments = {
		img_folder = "Assets/Attachments",
	},
	completion = {
		nvim_cmp = false,
	},
})

-- Quarto ------------------------------------------------------------------
require("quarto").setup({})

-- Todo-comments ------------------------------------------------
require("todo-comments").setup({})
