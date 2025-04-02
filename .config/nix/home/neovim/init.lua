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
	severity_sort = true,
	update_in_insert = false,
	virtual_text = {
		severity = {
			min = vim.diagnostic.severity.INFO,
			max = vim.diagnostic.severity.WARN,
		},
	},
	virtual_lines = {
		current_line = true,
		severity = {
			min = vim.diagnostic.severity.ERROR,
			max = vim.diagnostic.severity.ERROR,
		},
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
	if type(mode) == "table" then
		for _, m in ipairs(mode) do
			vim.api.nvim_set_keymap(m, lhs, rhs, options)
		end
	else
		vim.api.nvim_set_keymap(mode, lhs, rhs, options)
	end
end

-- Slime
g.slime_target = "neovim"

map("n", "<leader>rl", "<Plug>SlimeLineSend<Cr>", { desc = "Send line to Slime" })
map("n", "<leader>rr", "<Plug>SlimeRegionSend<Cr>", { desc = "Send region to Slime" })
map("v", "<leader>rr", "<Plug>SlimeRegionSend<Cr>", { desc = "Send region to Slime" })

-- Vim -----------------
-- jj to escape insert mode
map("i", "jj", "<Esc>", { desc = "jj to escape insert mode" })

-- Hide highlights
map("n", "<Esc>", "<Esc><Cmd>nohlsearch<Cr>")

-- Save file
map("n", "<C>s", ":w<Cr>", { desc = "Save file" })
map("n", "<C-a>", ":wa<Cr>", { desc = "Save all files" })

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
-- Line up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Plugin keymaps ----------------

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
map("n", "<leader>bd", "<Cmd>BufferLinePickClose<Cr>", { desc = "Delete buffer" })
map("n", "<leader>bl", "<Cmd>BufferLineCloseRight<Cr>", { desc = "Keep left buffer(s)" })
map("n", "<leader>bh", "<Cmd>BufferLineCloseLeft<Cr>", { desc = "Keep right buffer(s)" })

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
map("n", "<leader>fr", "<Cmd>FzfLua oldfiles<Cr>", { desc = "Recent files" })

-- LSP ------
map("n", "<leader>ls", "<Cmd>FzfLua lsp_document_symbols<Cr>", { desc = "Document symbols" })
map("n", "<leader>lS", "<Cmd>FzfLua lsp_workspace_symbols<Cr>", { desc = "Workspace symbols" })
map("n", "<leader>lD", "<Cmd>FzfLua lsp_definitions<Cr>", { desc = "Definitions" })
map("n", "<leader>lr", "<Cmd>FzfLua lsp_references<Cr>", { desc = "References" })
map("n", "<leader>la", "<Cmd>FzfLua lsp_code_actions<Cr>", { desc = "Code actions" })

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
map("n", "<leader>oc", "<Cmd>ObsidianToggleCheckbox<Cr>", { desc = "Toggle checkbox" })

-- Search ------
-- Todos
map("n", "<leader>st", "<Cmd>TodoFzfLua<Cr>", { desc = "Search todos" })
-- Help
map("n", "<leader>sh", "<Cmd>FzfLua helptags<Cr>", { desc = "Search help tags" })
-- Keymaps
map("n", "<leader>sk", "<Cmd>FzfLua keymaps<Cr>", { desc = "Search keymaps" })
-- Spelling
map("n", "<leader>ss", "<Cmd>FzfLua spell_suggest<Cr>", { desc = "Spelling suggestions" })
-- Registers
map("n", "<leader>sr", "<Cmd>FzfLua registers<Cr>", { desc = "Search registers" })

-- Flash search -----
map(
	{ "n", "x", "o" },
	"<leader>sj",
	"<Cmd>lua require('flash').jump({remote_op == { restore = true, motion = true },})<Cr>",
	{ desc = "Search jump (Flash)" }
)
map({ "n", "x", "o" }, "<leader>sp", "<Cmd>lua require('flash').treesitter()<Cr>", { desc = "Search phrase (Flash)" })

-- Toggle -------
map("n", "<leader>tt", "<Cmd>ToggleTerm direction=horizontal size=20<Cr>", { desc = "Toggle terminal" })
map("n", "<leader>tl", "<Cmd>SpellLang<Cr>", { desc = "Select spell language" })
map("n", "<leader>ts", "<Cmd>set spell!<Cr>", { desc = "Toggle spell" })

-- Spell Language Functionality
local function get_project_root()
	local current_file = vim.fn.expand("%:p")
	if current_file == "" then
		return nil
	end
	local path = vim.fn.fnamemodify(current_file, ":h")
	while path ~= "" and path ~= "/" do
		if vim.fn.isdirectory(path .. "/.git") == 1 or vim.fn.isdirectory(path .. "/.nvim_spell_lang") == 1 then
			return path
		end
		path = vim.fn.fnamemodify(path, ":h")
	end
	return nil
end

local function load_spell_lang()
	local project_root = get_project_root()
	if not project_root then
		return
	end
	local spell_lang_file = project_root .. "/.nvim_spell_lang"
	if vim.fn.filereadable(spell_lang_file) == 1 then
		local lang = vim.trim(vim.fn.readfile(spell_lang_file)[1])
		vim.opt_local.spelllang = lang
	else
		vim.opt_local.spelllang = "en_us"
	end
end

local function set_spell_lang(lang)
	local project_root = get_project_root()
	if not project_root then
		return
	end
	local spell_lang_file = project_root .. "/.nvim_spell_lang"
	vim.fn.writefile({ lang }, spell_lang_file)
	vim.opt_local.spelllang = lang
end

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		load_spell_lang()
	end,
})

vim.api.nvim_create_user_command("SpellLang", function()
	vim.ui.select({ "en_us", "es" }, {
		prompt = "Select spell language:",
	}, function(choice)
		if choice then
			set_spell_lang(choice)
		end
	end)
end, {})

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
opt.wrap = true

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

-- Spelling
opt.spell = false
opt.spelllang = { "en_us" }
opt.spellfile = os.getenv("HOME") .. "/.spell/en.utf-8.add"

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
opt.showmode = false

-- opt.mouse = "a"
