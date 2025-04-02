-- [A]utocommands -------------------------------------------------

local vim = vim
local a = vim.api

-- Create an autocommand group
-- personal

a.nvim_create_augroup("personal", { clear = true })

-- Highlight on yank
a.nvim_create_autocmd("TextYankPost", {
	group = "personal",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- -- Autocompletion (Nvim .11+)
-- a.nvim_create_autocmd("LspAttach", {
-- 	callback = function(ev)
-- 		local client = vim.lsp.get_client_by_id(ev.data.client_id)
-- 		if client:supports_method("textDocument/completion") then
-- 			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
-- 		end
-- 	end,
-- })

-- [D]iagnostics -------------------------------------------------

vim.diagnostic.config({
	virtual_lines = {
		current_line = true,
	},
})

-- [K]eymaps ------------------------------------------------------

local g = vim.g

-- Leader key
g.mapleader = " "
g.maplocalleader = " "

local function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Slime
g.slime_target = "neovim"

map("n", "<leader>rl", "<Plug>SlimeLineSend", { desc = "Send line to Slime" })
map("v", "<leader>rr", "<Plug>SlimeRegionSend", { desc = "Send region to Slime" })

-- Vim -----------------
-- jj to escape insert mode
map("i", "jj", "<Esc>", { desc = "jj to escape insert mode" })

-- Hide highlights
map("n", "<Esc>", "<Esc><Cmd>nohlsearch<Cr>")

-- Save file
map("n", "<C>s", ":w<Cr>", { desc = "Save file" })
map("n", "<C-a>", ":wa<Cr>", { desc = "Save all files" })

-- Close buffer
map("n", "<C-q>", ":bd<Cr>", { desc = "Close buffer" })
-- Split window
map("n", "<C-v>", ":vsplit<Cr>", { desc = "Split window vertically" })

-- Quit
map("n", "<leader>x", ":qa<Cr>", { desc = "Quit all" })

--- Window  -----
-- Move between
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize
map("n", "<leader>wk", "<C-w>-", { desc = "Resize window up" })
map("n", "<leader>wj", "<C-w>+", { desc = "Resize window down" })
map("n", "<leader>wh", "<C-w><", { desc = "Resize window left" })
map("n", "<leader>wl", "<C-w>>", { desc = "Resize window right" })

-- Go to
-- End of line
map("n", "gl", "$", { desc = "Go to end of line" })
-- Beginning of line
map("n", "gL", "^", { desc = "Go to beginning of line" })

-- Plugin keymaps ----------------

-- AI ------
-- Copilot
map("i", "<C-d>", "<Plug>(copilot-accept-word)", { desc = "Accept word" })
map("i", "<C-f>", "<Plug>(copilot-accept-line)", { desc = "Accept line" })
map("i", "<C-n>", "<Plug>(copilot-next)", { desc = "Next suggestion" })
map("i", "<C-p>", "<Plug>(copilot-previous)", { desc = "Previous suggestion" })
map("i", "<C-e>", "<Plug>(copilot-dismiss)", { desc = "Dismiss suggestion" })

-- CodeCompanion
map("n", "<leader>ag", "<Cmd>CodeCompanionChat gemini<Cr>", { desc = "CodeCompanion: Gemini" })
map("n", "<leader>ac", "<Cmd>CodeCompanionChat copilot<Cr>", { desc = "CodeCompanion: Copilot" })
map("n", "<leader>aa", "<Cmd>CodeCompanionActions<Cr>", { desc = "CodeCompanion actions" })

-- Buffers ------
-- Bufferline
map("n", "<Tab>", "<Cmd>BufferLineCycleNext<Cr>")
map("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<Cr>")
map("n", "<leader>bo", "<Cmd>BufferLineCloseOthers<Cr>", { desc = "Close other buffers" })
map("n", "<leader>bs", "<Cmd>BufferLineSortByDirectory<Cr>", { desc = "Sort by directory" })
map("n", "<leader>bS", "<Cmd>BufferLineSortByExtension<Cr>", { desc = "Sort by extension" })

-- Commands ------
-- ...

-- Diagnostics -----
--
map("n", "<leader>dd", "<Cmd>lua vim.diagnostic.open_float()<Cr>", { desc = "Show diagnostics" })

-- Explore -------
-- Neotree
map("n", "<leader>ee", "<Cmd>Neotree toggle<Cr>", { desc = "Toggle Neotree" })
map("n", "<leader>ef", "<Cmd>Neotree float<Cr>", { desc = "Float Neotree" })

-- Yazi
map("n", "<leader>ey", "<Cmd>Yazi<Cr>", { desc = "Yazi" })
map("n", "<leader>ec", "<Cmd>Yazi cwd<Cr>", { desc = "Yazi cwd" })

-- Find ------
-- Fzf-lua
map("n", "<leader>ff", "<Cmd>FzfLua files<Cr>", { desc = "Find files" })
map("n", "<leader>fg", "<Cmd>FzfLua live_grep<Cr>", { desc = "Live grep" })

-- Markdown ------
-- Unordered list item
map("n", "<leader>mu", "I- ", { desc = "Unordered list item" })
map("v", "<leader>mu", ":s/^/- /<CR>gv", { desc = "Unordered list item" })
-- Ordered list item
map("n", "<leader>mo", "I1. ", { desc = "Ordered list item" })
map("v", "<leader>mo", ":s/^/1. /<CR>gv", { desc = "Ordered list item" })
--- Task list item
map("n", "<leader>mt", "I- [ ] ", { desc = "Task list item" })
map("v", "<leader>mt", ":s/^/- [ ] /<CR>gv", { desc = "Task list item" })
-- Styled text
map("v", "<leader>mb", 'c**<C-r>"**<Esc>', { desc = "Bold" })
map("v", "<leader>mi", 'c*<C-r>"*<Esc>', { desc = "Italic" })
map("v", "<leader>mu", 'c~~<C-r>"~~<Esc>', { desc = "Strikethrough" })
--- Code blocks
map("v", "<leader>mc", 'c```\n<C-r>"\n```<Esc>', { desc = "Code Block" })
map("v", "<leader>mk", 'c`<C-r>"`<Esc>', { desc = "Inline Code" })
-- Headings
map("n", "<leader>m1", "I# ", { desc = "Heading 1" })
map("n", "<leader>m2", "I## ", { desc = "Heading 2" })
map("n", "<leader>m3", "I### ", { desc = "Heading 3" })
map("n", "<leader>m4", "I#### ", { desc = "Heading 4" })
-- Links
map("v", "<leader>ml", 'c[<C-r>"](<Esc>i)', { desc = "Add link" })

-- Obsidian ------
map("n", "<leader>od", "<Cmd>ObsidianDailies<Cr>", { desc = "Daily note" })
map("n", "<leader>on", "<Cmd>ObsidianNew<Cr>", { desc = "New note" })
map("n", "<leader>oN", "<Cmd>ObsidianNewFromTemplate<Cr>", { desc = "New from template" })
map("n", "<leader>oi", "<Cmd>ObsidianPasteImg<Cr>", { desc = "Paste image" })
map("n", "<leader>ol", "<Cmd>ObsidianLinkNew<Cr>", { desc = "New link" })
map("n", "<leader>of", "<Cmd>ObsidianFollowLink<Cr>", { desc = "Follow link" })
map("n", "<leader>or", "<Cmd>ObsidianRename<Cr>", { desc = "Rename note" })

-- Search ------
-- Todos
map("n", "<leader>st", "<Cmd>TodoFzfLua<Cr>", { desc = "Search todos" })
-- Help
map("n", "<leader>sh", "<Cmd>FzfLua helptags<Cr>", { desc = "Search help tags" })

-- [O]ptions ------------------------------------------------------

local opt = vim.opt

-- Clipboard
opt.clipboard = "unnamedplus"

-- Completions
opt.completeopt = "menu,preview,noselect"

-- Window
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 3
opt.sidescrolloff = 5
opt.wrap = false

-- Gutter
opt.relativenumber = true
opt.number = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.cursorlineopt = "number"

-- Tabs
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.showtabline = 2

-- Indentation
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true
opt.linebreak = true
opt.showbreak = "↪ "

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = false

-- Swap/backup/undo
opt.backup = false
opt.swapfile = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

-- Colors
opt.termguicolors = true
opt.background = "dark"
vim.cmd("colorscheme gruvbox")

-- Misc
opt.winborder = "rounded"

-- opt.mouse = "a"
