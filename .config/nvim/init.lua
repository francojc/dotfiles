--| Bootstrap paq-nvim -------------------------------------------
-- Ensure paq-nvim is installed before trying to use it
require("bootstrap").ensure_paq()

--| Paq: plugins -------------------------------------------------
require("paq")({
	"3rd/image.nvim", -- Image support in Neovim
	"MeanderingProgrammer/render-markdown.nvim", -- Render-Markdown
	"Saghen/blink.cmp", -- Blink completion
	"akinsho/bufferline.nvim", -- Bufferline
	"akinsho/toggleterm.nvim", -- Toggle terminal
	"echasnovski/mini.icons", -- Icons
	"echasnovski/mini.indentscope", -- Indent guides
	"echasnovski/mini.pairs", -- Pairs
	"echasnovski/mini.surround", -- Surround
	"ellisonleao/gruvbox.nvim", -- Colorscheme: Gruvbox
	"folke/flash.nvim", -- Flash jump
	"folke/todo-comments.nvim", -- Todo comments highlighting/searching
	"folke/which-key.nvim", -- Keymaps popup
	"github/copilot.vim", -- Copilot
	"goolord/alpha-nvim", -- Alpha dashboard
	"hakonharnes/img-clip.nvim", -- Image pasting
	"ibhagwan/fzf-lua", -- FZF fuzzy finder
	"jmbuhr/cmp-pandoc-references", -- Pandoc references
	"jmbuhr/otter.nvim", -- Otter for Quarto
	"jpalardy/vim-slime", -- Slime integration
	"kdheepak/lazygit.nvim", -- Lazygit integration
	"lewis6991/gitsigns.nvim", -- Git signs
	"lilydjwg/colorizer", -- Colorizer
	"mikavilpas/yazi.nvim", -- Yazi file manager integration
	"moyiz/blink-emoji.nvim", -- Blink emoji
	"neovim/nvim-lspconfig", -- LSP
	"nvim-lua/plenary.nvim", -- Plenary for Lua functions
	"nvim-lualine/lualine.nvim", -- Statusline
	"nvim-treesitter/nvim-treesitter", -- Treesitter
	"obsidian-nvim/obsidian.nvim", -- Obsidian integration
	"olimorris/codecompanion.nvim", -- Code companion AI integration
	"quarto-dev/quarto-nvim", -- Quarto integration
	"rafamadriz/friendly-snippets", -- Snippets
	"rcarriga/nvim-notify", -- Notifications
	"rmagatti/auto-session", -- Auto session management
	"savq/paq-nvim", -- Paq manages itself
	"stevearc/aerial.nvim", -- Code outline
	"stevearc/conform.nvim", -- Formatter
	"j-hui/fidget.nvim", -- LSP progress indicator
	"christoomey/vim-tmux-navigator", -- nav through vim/tmux
	"sindrets/diffview.nvim", -- Git diff viewer
})

--| Options ------------------------------------------------------
local a = vim.api
local opt = vim.opt

-- Globals -----
-- Record start time for startup duration
_G.nvim_config_start_time = vim.loop.hrtime()

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Locals -----
-- Clipboard
opt.clipboard = "unnamedplus"
-- Completions
opt.completeopt = "menu,menuone,noselect"
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
-- Display chars
opt.list = false
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
-- Misc
opt.winborder = "rounded"
opt.showmode = false
opt.cmdheight = 0
opt.formatexpr = "v:lua.require('conform').formatexpr()"

opt.laststatus = 2 -- show statusline always

-- Diagnostics
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

--| Autocommands -------------------------------------------------
-- Create an autocommand group
-- personal group
a.nvim_create_augroup("personal", { clear = true })
-- Highlight on yank
a.nvim_create_autocmd("TextYankPost", {
	group = "personal",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank()
	end,
})

--| Keymaps ------------------------------------------------------
local g = vim.g

-- Leader key -----
g.mapleader = " "
g.maplocalleader = " "

-- map() function -----
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

-- Vim -----------------
-- jj to escape insert mode
map("i", "jj", "<Esc>", { desc = "jj to escape insert mode" })
-- jj to escape terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })
-- Hide highlights
map("n", "<Esc>", "<Esc><Cmd>nohlsearch<Cr>")
-- Save file
map("n", "<C-s>", ":w<Cr>", { desc = "Save file" })
map("n", "<C-a>", ":wa<Cr>", { desc = "Save all files" })
-- Quit
map("n", "<leader>x", ":qa<Cr>", { desc = "Quit" })
-- Delete session and quit
map("n", "<leader>X", "<Cmd>SessionDelete<CR><Cmd>qa<CR>", { desc = "Quit (session)" })
--- Window  -----
-- Move between editor/terminal windows
map({ "n", "t" }, "<C-h>", "<Cmd>wincmd h<Cr>", { desc = "Move to left window" })
map({ "n", "t" }, "<C-j>", "<Cmd>wincmd j<Cr>", { desc = "Move to bottom window" })
map({ "n", "t" }, "<C-k>", "<Cmd>wincmd k<Cr>", { desc = "Move to top window" })
map({ "n", "t" }, "<C-l>", "<Cmd>wincmd l<Cr>", { desc = "Move to right window" })

-- Resize
map("n", "<leader>wk", "<C-w>5-", { desc = "Resize window up" })
map("n", "<leader>wj", "<C-w>5+", { desc = "Resize window down" })
map("n", "<leader>wh", "<C-w>5<", { desc = "Resize window left" })
map("n", "<leader>wl", "<C-w>5>", { desc = "Resize window right" })
-- Go to
-- Beginning of line
map({ "n", "v" }, "gh", "^", { desc = "Go to beginning of line" })
-- End of line
map({ "n", "v" }, "gl", "$", { desc = "Go to end of line" })
map({ "n", "v" }, "go", "o<Esc>", { desc = "Add line below current line" })
-- Line up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
-- Next visual line
map("n", "j", "gj", { desc = "Next visual line" })
map("n", "k", "gk", { desc = "Previous visual line" })
-- Window-centered movement
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Previous search result" })
-- Paste without overwriting register
map("v", "p", '"_dP', { desc = "Paste without overwriting register" })

-- Plugin keymaps ----------------
-- Copilot
g.copilot_settings = { selectedCompletionModel = "gpt-4o-copilot" } -- INFO: this works, but there only seems to be one model available 2025-06-03
map("i", "<C-f>", "copilot#Accept('\\<Cr>')", { expr = true, replace_keycodes = false, desc = "Accept suggestion" })
g.copilot_no_tab_map = true -- Disable default tab mapping

map("i", "<Tab>", "<Plug>(copilot-accept-word)", { desc = "Accept word" })
map("i", "<C-d>", "<Plug>(copilot-accept-line)", { desc = "Accept line" })
map("i", "<C-n>", "<Plug>(copilot-next)", { desc = "Next suggestion" })
map("i", "<C-p>", "<Plug>(copilot-previous)", { desc = "Previous suggestion" })
map("i", "<C-e>", "<Plug>(copilot-dismiss)", { desc = "Dismiss suggestion" })

-- CodeCompanion
map("n", "<leader>aa", "<Cmd>CodeCompanionChat Toggle<Cr>", { desc = "CodeCompanion: Toggle" })
map("n", "<leader>ag", "<Cmd>CodeCompanionChat gemini<Cr>", { desc = "CodeCompanion: Gemini" })
map("n", "<leader>ac", "<Cmd>CodeCompanionChat copilot<Cr>", { desc = "CodeCompanion: Copilot" })
map("n", "<leader>ax", "<Cmd>CodeCompanionActions<Cr>", { desc = "CodeCompanion actions" })
map({ "n", "v" }, "<leader>ae", "<Cmd>CodeCompanion /explain<Cr>", { desc = "CodeCompanion: Explain" })
map("v", "<leader>al", "<Cmd>CodeCompanion /lsp<Cr>", { desc = "CodeCompanion: LSP" })
map("v", "<leader>af", "<Cmd>CodeCompanion /fix<Cr>", { desc = "CodeCompanion: Fix" })
map("v", "<leader>at", "<Cmd>CodeCompanion /tests<Cr>", { desc = "CodeCompanion: Tests" })

-- Buffers --------------------------
-- Bufferline
map("n", "<Tab>", "<Cmd>BufferLineCycleNext<Cr>")
map("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<Cr>")
map("n", "<leader>bo", "<Cmd>BufferLineCloseOthers<Cr>", { desc = "Close other buffers" })
map("n", "<leader>bs", "<Cmd>BufferLineSortByDirectory<Cr>", { desc = "Sort by directory" })
map("n", "<leader>bS", "<Cmd>BufferLineSortByExtension<Cr>", { desc = "Sort by extension" })
map("n", "<leader>bd", "<Cmd>BufferLinePickClose<Cr>", { desc = "Delete buffer" })
map("n", "<leader>bl", "<Cmd>BufferLineCloseRight<Cr>", { desc = "Keep left buffer(s)" })
map("n", "<leader>bh", "<Cmd>BufferLineCloseLeft<Cr>", { desc = "Keep right buffer(s)" })
map("n", "<leader>bf", "<Cmd>FzfLua buffers<Cr>", { desc = "Buffer find" })

-- Code -----------------------------
map("n", "<leader>ca", "<Cmd>lua require('fzf-lua').lsp_code_actions()<Cr>", { desc = "Code actions" })
map(
	{ "n", "v" },
	"<leader>cf",
	"<Cmd>lua require('conform').format({lsp_format = 'fallback'})<Cr>",
	{ desc = "Code format" }
)
map("n", "<leader>cn", "<Cmd>s/\\s\\+/ /g<CR>", { desc = "Remove extra spaces (current line)" })
map("v", "<leader>cn", ":s/\\s\\+/ /g<CR>", { desc = "Remove extra spaces (selected lines)" })

-- Diagnostics/Debug -----------------------------
--
map("n", "<leader>dd", "<Cmd>lua vim.diagnostic.open_float()<Cr>", { desc = "Show diagnostics" })

-- Explore -------------------------------
-- Yazi
map("n", "<leader>ey", "<Cmd>Yazi<Cr>", { desc = "Yazi" })
map("n", "<leader>ec", "<Cmd>Yazi cwd<Cr>", { desc = "Yazi cwd" })
-- Files -----------------------------------
-- Fzf-lua
map("n", "<leader>ff", "<Cmd>FzfLua files<Cr>", { desc = "Find files" })
map("n", "<leader>fg", "<Cmd>FzfLua live_grep resume=true<Cr>", { desc = "Live grep" })
map("n", "<leader>fn", "<Cmd>enew<Cr>", { desc = "New file" })
map("n", "<leader>fr", "<Cmd>FzfLua oldfiles<Cr>", { desc = "Recent files" })
map("n", "<leader>fc", "<Cmd>FzfLua resume<Cr>", { desc = "Resume fzf" })
-- Git -----------------------------------
-- Lazygit
map("n", "<leader>gg", "<Cmd>LazyGit<Cr>", { desc = "Lazygit" })
map("n", "<leader>gl", "<Cmd>LazyGitLog<Cr>", { desc = "Lazygit log" })
-- Diffview
map("n", "<leader>gd", "<Cmd>DiffviewOpen<Cr>", { desc = "Diffview open" })
map("n", "<leader>gD", "<Cmd>DiffviewOpen HEAD~1<Cr>", { desc = "Diffview compare with previous" })
map("n", "<leader>gh", "<Cmd>DiffviewFileHistory<Cr>", { desc = "File history (current)" })
map("n", "<leader>gH", "<Cmd>DiffviewFileHistory %<Cr>", { desc = "File history (all)" })
map("n", "<leader>gc", "<Cmd>DiffviewClose<Cr>", { desc = "Diffview close" })
map("n", "<leader>gf", "<Cmd>lua require('diffview').emit('focus_files')<Cr>", { desc = "Focus file panel" })
map("n", "<leader>gt", "<Cmd>lua require('diffview').emit('toggle_files')<Cr>", { desc = "Toggle file panel" })
-- LSP -----------------------------------
map("n", "<leader>ls", "<Cmd>FzfLua lsp_document_symbols<Cr>", { desc = "Document symbols" })
map("n", "<leader>lS", "<Cmd>FzfLua lsp_workspace_symbols<Cr>", { desc = "Workspace symbols" })
map("n", "<leader>lD", "<Cmd>FzfLua lsp_definitions<Cr>", { desc = "Definitions" })
map("n", "<leader>lr", "<Cmd>FzfLua lsp_references<Cr>", { desc = "References" })
map("n", "<leader>ln", "<Cmd>lua vim.lsp.buf.rename()<Cr>", { desc = "Rename" })
-- Markdown -----------------------------------
-- Unordered list item
map("n", "<leader>mu", "I- ", { desc = "Unordered list item" })
map("v", "<leader>mu", ":s/^/- /g<CR>gv", { desc = "Unordered list item" })
-- Ordered list item
map("n", "<leader>mo", "I1. ", { desc = "Ordered list item" })
map("v", "<leader>mo", ":s/^/1. /g<CR>gv", { desc = "Ordered list item" })
--- Task list item
map("n", "<leader>mt", "I- [ ] ", { desc = "Task list item" })
map("v", "<leader>mt", ":s/^/- [ ] /<CR>gv", { desc = "Task list item" })
-- Styled text
map("v", "<leader>mb", 'c**<C-r>"**<Esc>', { desc = "Bold" })
map("v", "<leader>mi", 'c*<C-r>"*<Esc>', { desc = "Italic" })
map("v", "<leader>ms", 'c~~<C-r>"~~<Esc>', { desc = "Strikethrough" })
--- Code blocks
map("v", "<leader>mc", 'c```\n<C-r>"\n```<Esc>', { desc = "Code Block" })
map("v", "<leader>mC", 'c`<C-r>"`<Esc>', { desc = "Inline Code" })
-- Headings
map("n", "<leader>m1", "I# ", { desc = "Heading 1" })
map("n", "<leader>m2", "I## ", { desc = "Heading 2" })
map("n", "<leader>m3", "I### ", { desc = "Heading 3" })
map("n", "<leader>m4", "I#### ", { desc = "Heading 4" })
-- Links
map("v", "<leader>ml", 'c[<C-r>"]()<Left>', { desc = "Add link" })
-- Paste image
map(
	"n",
	"<leader>mp",
	"<Cmd>lua require('img-clip').paste_image({dir_path = 'images', relative_to_current_file = true })<Cr>",
	{ desc = "Paste image" }
)
-- Obsidian -----------------------------------
map("n", "<leader>oN", "<Cmd>ObsidianNewFromTemplate<Cr>", { desc = "New from template" })
map("n", "<leader>oc", "<Cmd>ObsidianToggleCheckbox<Cr>", { desc = "Toggle checkbox" })
map("n", "<leader>od", "<Cmd>ObsidianDailies<Cr>", { desc = "Daily note" })
map("n", "<leader>ot", "<Cmd>ObsidianTomorrow<Cr>", { desc = "Tomorrow note" })
map("n", "<leader>of", "<Cmd>ObsidianFollowLink<Cr>", { desc = "Follow link" })
map("n", "<leader>oi", "<Cmd>ObsidianPasteImg<Cr>", { desc = "Paste image" })
map("n", "<leader>ol", "<Cmd>ObsidianLinkNew<Cr>", { desc = "New link" })
map("n", "<leader>on", "<Cmd>ObsidianNew<Cr>", { desc = "New note" })
map("n", "<leader>or", "<Cmd>ObsidianRename<Cr>", { desc = "Rename note" })

-- Quarto -----------------------------------
map("n", "<C-CR>", "<Cmd>QuartoSend<Cr>", { desc = "Quarto: send cell" })
map("n", "<leader>qa", "<Cmd>QuartoSendAbove<Cr>", { desc = "Quarto: send above" })
map("n", "<leader>qb", "<Cmd>QuartoSendBelow<Cr>", { desc = "Quarto: send below" })
map("n", "<leader>qf", "<Cmd>QuartoSendAll<Cr>", { desc = "Quarto: send file" })

-- Run -----------------------------------
-- Slime
g.slime_target = "tmux"
vim.api.nvim_create_autocmd("FileType", {
	-- limit to only certain filetypes
	pattern = { "r", "quarto", "markdown" },
	callback = function()
		vim.b.slime_cell_delimiter = "```"
	end,
})

-- vim.b.slime_cell_delimiter = "```"
map("n", "<leader>rl", "<Plug>SlimeLineSend<Cr>", { desc = "Send line to Slime" })
map("n", "<leader>rr", "<Plug>SlimeRegionSend<Cr>", { desc = "Send region to Slime" })
map("v", "<leader>rr", "<Plug>SlimeRegionSend<Cr>", { desc = "Send region to Slime" })

-- Search -----------------------------------
map("n", "<leader>sh", "<Cmd>FzfLua helptags<Cr>", { desc = "Search help tags" })
map("n", "<leader>sk", "<Cmd>FzfLua keymaps<Cr>", { desc = "Search keymaps" })
map("n", "<leader>sm", "<Cmd>FzfLua marks<Cr>", { desc = "Search marks" })
map("n", "<leader>sr", "<Cmd>FzfLua registers<Cr>", { desc = "Search registers" })
map("n", "<leader>ss", "<Cmd>FzfLua spell_suggest<Cr>", { desc = "Spelling suggestions" })
map("n", "<leader>st", "<Cmd>TodoFzfLua<Cr>", { desc = "Search todos" })
-- Flash search
map({ "n", "x", "o" }, "<leader>sf", "<Cmd>lua require('flash').jump()<Cr>", { desc = "Flash" })
map({ "n", "x", "o" }, "<leader>sF", "<Cmd>lua require('flash').treesitter()<Cr>", { desc = "Flash treesitter" })

-- Toggle ------------------------------------
map("n", "<leader>ta", "<Cmd>AerialToggle!<Cr>", { desc = "Toggle aerial" })
map("n", "<leader>tf", "<Cmd>lua require('flash').toggle()<Cr>", { desc = "Toggle flash" })
map("n", "<leader>ti", "<Cmd>lua Toggle_image_rendering()<CR>", { desc = "Toggle image rendering" })
map("n", "<leader>tl", "<Cmd>SpellLang<Cr>", { desc = "Select spell language" })
map("n", "<leader>tr", "<Cmd>lua Toggle_r_language_server()<CR>", { desc = "Toggle R LSP" }) -- Call the Lua function
map("n", "<leader>ts", "<Cmd>set spell!<Cr>", { desc = "Toggle spell" })
map("n", "<leader>tt", "<Cmd>ToggleTerm direction=float<Cr>", { desc = "Toggle terminal float" })

---| Toggle functions --------------------------------------------

-- Image Rendering Toggle Functionality
Image_rendering_enabled = false -- Assume images are disabled by default -- Make global
function _G.Toggle_image_rendering() -- Make global
	if Image_rendering_enabled then
		require("image").disable()
		vim.notify("Image rendering disabled", vim.log.levels.INFO, { title = "Image" })
	else
		require("image").enable()
		vim.notify("Image rendering enabled", vim.log.levels.INFO, { title = "Image" })
	end
	Image_rendering_enabled = not Image_rendering_enabled
end

-- Toggle R language server using standard vim.lsp APIs
function _G.Toggle_r_language_server()
	local clients = vim.lsp.get_clients({ bufnr = 0, name = "r_language_server" })

	if #clients > 0 then
		-- LSP is running for this buffer, stop all R clients for this buffer
		vim.notify("Stopping R LSP client(s) for current buffer...", vim.log.levels.INFO, { title = "R LSP" })
		for _, client in ipairs(clients) do
			vim.lsp.stop_client(client.id)
		end
	else
		-- LSP is not running for this buffer, start it
		vim.notify("Starting R LSP for current buffer...", vim.log.levels.INFO, { title = "R LSP" })
		-- We need configuration details to start the client manually
		local lspconfig_util = require("lspconfig.util")
		local bufname = vim.api.nvim_buf_get_name(0)
		local root_dir = lspconfig_util.root_pattern("DESCRIPTION")(bufname)
			or lspconfig_util.find_git_ancestor(bufname)
			or lspconfig_util.path.dirname(bufname)

		if root_dir then
			vim.lsp.start({
				name = "r_language_server",
				cmd = { "R", "--slave", "-e", "languageserver::run()" },
				root_dir = root_dir,
				capabilities = capabilities,
				filetypes = { "r" }, -- Ensure filetype association
			})
		else
			vim.notify("Could not determine project root for R LSP.", vim.log.levels.WARN, { title = "R LSP" })
		end
	end
end

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

-- Plugin configuration ----------------------------------------------
-- Aerial ----------------------------------
require("aerial").setup({
	on_attach = function(bufnr)
		-- Jump forwards/backwards with '{' and '}'
		vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
		vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
	end,
})

-- Alpha ----------------------------------
local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set header

dashboard.section.header.val = {
	-- NEOVIM
	"                                                     ",
	"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
	"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
	"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
	"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
	"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
	"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
	"                                                     ",
}
-- Set menu
dashboard.section.buttons.val = {
	dashboard.button("r", "  Recent files", ":FzfLua oldfiles<CR>"),
	dashboard.button("f", "  Find file", ":FzfLua files<CR>"),
	dashboard.button("g", "  Find text", ":FzfLua live_grep <CR>"),
	dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("s", "  Select a session", ":SessionSearch<CR>"),
	dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
}

-- Set footer
dashboard.section.footer.val = function()
	local end_time = vim.loop.hrtime()
	local start_time = _G.nvim_config_start_time or end_time -- Fallback if start time wasn't set
	local duration_ns = end_time - start_time
	local ms = math.floor(duration_ns / 1000000 + 0.5) -- Convert ns to ms and round
	return " Welcome back, " .. os.getenv("USER") .. "! Loaded in " .. ms .. "ms"
end

-- Configure alpha options to handle UI automatically
dashboard.config.opts.setup = function()
	vim.opt_local.foldenable = false
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.opt_local.signcolumn = "no"
	vim.b.ministatusline_disable = true
	vim.b.miniindentscope_disable = true
end

-- Send config to alpha
alpha.setup(dashboard.config)

-- Auto-session -------------------------------
require("auto-session").setup({
	auto_restore = true,
	bypass_save_filetypes = { "alpha", "dashboard", "codecompanion" },
})

-- Blink ----------------------------------
-- Timer for delayed auto_show
local completion_timer = nil

require("blink.cmp").setup({
	fuzzy = {
		implementation = "lua",
	},
	completion = {
		list = {
			selection = {
				preselect = false,
				auto_insert = false,
			},
		},
		menu = {
			auto_show = function(ctx)
				-- Don't show if we're at the end of a line with only whitespace after cursor
				local line = vim.api.nvim_get_current_line()
				local col = vim.api.nvim_win_get_cursor(0)[2]
				local after_cursor = line:sub(col + 1)
				if after_cursor:match("^%s*$") then
					return false
				end
				-- Cancel any existing timer
				if completion_timer then
					vim.fn.timer_stop(completion_timer)
					completion_timer = nil
				end
				-- Start a new timer for 1000ms delay
				completion_timer = vim.fn.timer_start(1000, function()
					require("blink.cmp").show()
					completion_timer = nil
				end)
				-- Return false to prevent immediate showing
				return false
			end,
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
		-- preset = "enter", -- with mods
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
			markdown = { "path", "snippets", "lsp", "references", "emoji" },
			quarto = { "path", "snippets", "lsp", "references", "emoji" },
		},
		providers = {
			emoji = {
				name = "Emoji",
				module = "blink-emoji",
			},
			references = {
				name = "pandoc_references",
				module = "cmp-pandoc-references.blink",
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

-- Bufferline ----------------------------------
require("bufferline").setup({
	highlights = {
		fill = {
			fg = "#EBDBB2",
			bg = "#3C3836",
		},
		close_button = {
			fg = "#EBDBB2",
			bg = "#3C3836",
		},
		close_button_visible = {
			fg = "#EBDBB2",
			bg = "#3C3836",
		},
		close_button_selected = {
			fg = "#EBDBB2",
			bg = "#3C3836",
		},
		background = {
			italic = false,
			bold = false,
			fg = "#EBDBB2",
			bg = "#3C3836",
		},
		buffer_visible = {
			italic = false,
			bold = false,
			fg = "#EBDBB2",
			bg = "#3C3836",
		},
		buffer_selected = {
			italic = false,
			bold = true,
			fg = "#FABD2E",
			bg = "#3C3836",
		},
		modified = {
			bg = "#3C3836",
		},
		modified_selected = {
			bg = "#3C3836",
		},
		separator = {
			bg = "#3C3836",
		},
		separator_visible = {
			bg = "#3C3836",
		},
		separator_selected = {
			bg = "#FABD2E",
			fg = "#FABD2E",
		},
		offset_separator = {
			bg = "#3C3836",
		},
		pick_selected = {
			bg = "#3C3836",
		},
		pick_visible = {
			bg = "#3C3836",
		},
		pick = {
			bg = "#3C3836",
			bold = true,
			italic = true,
		},
	},
	options = {
		color_icons = true,
		separator_style = "thin",
		indicator = {
			style = "none",
		},
	},
})

-- CodeCompanion ----------------------------------
require("codecompanion").setup({
	opts = {
		show_model_choices = false,
	},
	adapters = {
		-- Use sonnet with Copilot
		copilot = function()
			return require("codecompanion.adapters").extend("copilot", {
				schema = {
					model = {
						default = "claude-sonnet-4",
					},
				},
			})
		end,
		-- Use gemini-2.5-pro-exp-03-25 with Gemini
		gemini = function()
			return require("codecompanion.adapters").extend("gemini", {
				schema = {
					model = { default = "gemini-2.5-pro-exp-03-25" },
				},
			})
		end,
	},
	strategies = {
		chat = {
			adapter = "copilot",
			roles = {
				---@diagnostic disable-next-line: undefined-doc-name
				---@type string|fun(adapter: CodeCompanion.Adapter): string
				llm = function(adapter)
					---@diagnostic disable-next-line: undefined-field
					return " (" .. adapter.formatted_name .. ") "
				end,

				---@type string
				user = " -------------",
			},
		},
		inline = {
			adapter = "copilot",
		},
	},
})

-- Colorscheme ----------------------------------
-- Gruvbox
require("gruvbox").setup({
	invert_selection = true,
	contrast = "hard",
	overrides = {},
})

vim.cmd("colorscheme gruvbox")

-- Conform ----------------------------------
require("conform").setup({
	default_format_ops = {
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		bash = { "shfmt" },
		json = { "jq" },
		jsonl = { "jq" },
		lua = { "stylua" },
		markdown = { "mdformat" },
		nix = { "alejandra" },
		python = { "ruff", lsp_format = "fallback" },
		r = { "air" },
		["*"] = { "trim_whitespace" },
	},
	format_on_save = function()
		-- Do not format markdown/quarto files on save
		local ft = vim.bo.filetype
		if ft == "markdown" or ft == "quarto" then
			return false
		end
		return {
			timeout_ms = 500,
			lsp_format = "fallback",
		}
	end,
	notify_on_error = false,
})

-- Fidget ----------------------------------
require("fidget").setup({
	notification = {
		window = {
			winblend = 80, -- 80% transparency
			border = "none", -- Clean look without borders
		},
	},

	progress = {
		display = {
			done_icon = "✓", -- Clean checkmark for completed tasks
			done_style = "DiagnosticOk", -- Green styling for completed
			progress_icon = {
				pattern = "dots_pulse", -- Smooth pulsing animation
				period = 1,
			},
			progress_style = "DiagnosticInfo", -- Blue styling for progress
			group_style = "Title", -- Bold styling for LSP server names
			render_limit = 8, -- Limit notifications to avoid clutter
			done_ttl = 2, -- Show completed tasks for 2 seconds
		},
	},
})

-- Flash ----------------------------------
require("flash").setup({})

-- FZF ----------------------------------
require("fzf-lua").setup({
	file_icon_padding = " ",
	files = {
		git_icons = true,
		formatter = "path.filename_first",
	},
	oldfiles = {
		cwd_only = true,
		include_current_session = true,
	},
})

-- Gitsigns -------------------------------
require("gitsigns").setup()

-- Hardtime ----------------------------------
-- require("hardtime").setup({})

-- Image ----------------------------------
require("image").setup({
	processor = "magick_cli",
	integrations = {
		markdown = {
			-- clear_in_insert_mode = true, -- Disable this to test flicker
			clear_in_insert_mode = false,
			filetypes = { "markdown", "quarto" },
			-- only_render_image_at_cursor = true, -- Disable this to test flicker
			only_render_image_at_cursor = false,
		},
	},
})

-- Img-Clip ----------------------------------
require("img-clip").setup({
	default = {
		dir_path = "./images",
		relative_to_current_file = true,
		show_dir_path_in_prompt = true,
	},
})

-- Lspconfig --------------------------------
-- LSP
local lspconfig = require("lspconfig")

-- Get enhanced LSP capabilities from blink.cmp
-- Define capabilities early so the toggle function can access it
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Bash
-- bash-language-server
lspconfig.bashls.setup({ capabilities = capabilities })
-- Lua
-- lua-lanuage-server
lspconfig.lua_ls.setup({ capabilities = capabilities })
-- Nix
-- nixd

local function get_home_dir()
	return os.getenv("HOME") or "~"
end

local function get_hostname()
	return os.getenv("HOSTNAME") or vim.loop.os_gethostname() or ""
end

lspconfig.nixd.setup({
	cmd = { "nixd" },
	capabilities = capabilities,
	settings = {
		nixd = {
			nixpkgs = { expr = "import <nixpkgs> {}" },
			formatting = { command = { "alejandra" } },
			options = {
				nixos = {
					expr = '(builtins.getFlake get_home_dir() .. "/.dotfiles/.config/nix").nixosConfigurations.'
						.. get_hostname()
						.. ".options",
				},
				nix_darwin = {
					expr = '(builtins.getFlake get_home_dir() .. "/.dotfiles/.config/nix").darwinConfigurations.'
						.. get_hostname()
						.. ".options",
				},
				home_manager = {
					expr = '(builtins.getFlake get_home_dir() .. "/.dotfiles/.config/nix").homeConfigurations.'
						.. get_hostname()
						.. ".options",
				},
			},
		},
	},
})
-- Python
lspconfig.pyright.setup({ capabilities = capabilities })

-- R
-- https://posit-dev.github.io/air/editor-neovim.html
require("lspconfig").air.setup({
	on_attach = function(_, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format()
			end,
		})
	end,
})

lspconfig.r_language_server.setup({
	on_attach = function(client, _)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	cmd = { "R", "--slave", "-e", "languageserver::run()" },
	filetypes = { "r" },
	capabilities = capabilities,
	root_dir = function(fname)
		return lspconfig.util.root_pattern("DESCRIPTION")(fname)
			or lspconfig.util.find_git_ancestor(fname)
			or lspconfig.util.path.dirname(fname)
	end,
	settings = {
		r = {
			diagnostics = {
				enable = true,
				globals = { "vim" },
			},
		},
	},
})

-- YAML
-- yaml-language-server

-- Dynamically detect Quarto YAML schema and configure yamlls
local function get_quarto_resource_path()
	-- error handling for io.popen
	local ok, f = pcall(io.popen, "quarto --paths", "r")
	if not ok or not f then
		return nil
	end
	-- Function to split a string by a delimiter
	local function strsplit(s, delimiter)
		local result = {}
		for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
			table.insert(result, match)
		end
		return result
	end
	local s = f:read("*a")
	f:close()
	local lines = strsplit(s, "\n")
	-- The second line is usually the system share path
	return lines[2]
end

local resource_path = get_quarto_resource_path()
local quarto_schema_path = resource_path and (resource_path .. "/schemas/quarto-schema.json") or nil

if quarto_schema_path then
	lspconfig.yamlls.setup({
		capabilities = capabilities,
		settings = {
			yaml = {
				schemas = {
					[quarto_schema_path] = { "*.qmd", ".quarto.yaml", "quarto.yml", "*.quarto.yml" },
				},
				completion = true,
				validate = true,
			},
		},
	})
else
	lspconfig.yamlls.setup({ capabilities = capabilities })
end

-- Lualine ----------------------------------------------------------------
-- Lualine setup
require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = " ", right = " " },
		section_separators = { left = " ", right = " " },
		disabled_filetypes = {
			statusline = { "toggleterm", "alpha", "codecompanion", "aerial" },
			winbar = { "alpha" },
		},
		always_divide_middle = true,
		globalstatus = false, -- conflicts with statusline = 2
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = {
			{ "filename", path = 1 },
		},
		lualine_x = {},
		lualine_y = {
			{ " filetype", icon_only = true },
		},
		lualine_z = { "progress" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
})

-- Mini -----------------------------------
require("mini.icons").setup({})
require("mini.pairs").setup({})
require("mini.indentscope").setup({})
require("mini.surround").setup({})

-- Obsidian -----------------------------------
require("obsidian").setup({
	ui = {
		enable = true,
	},
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
		blink = true,
	},
})

-- Precognition -------------------------------
-- require("precognition").setup({})

-- Quarto -----------------------------------
require("quarto").setup({})

-- Render-Markdown ---------------------------
require("render-markdown").setup({
	bullet = {
		icons = { "■ ", "□ ", "▪ ", "▫ " },
		left_pad = 0,
		right_pad = 2,
	},
	checkbox = {
		unchecked = { icon = "□ ", highlight = "RenderMarkdownUnchecked" },
		checked = { icon = " ", highlight = "RenderMarkdownChecked" },
		custom = {
			todo = { raw = "[-]", rendered = " ", highlight = "DiagnosticInfo", scope_highlight = nil },
			forward = { raw = "[>]", rendered = " ", highlight = "DiagnosticError", scope_highlight = nil },
			important = { raw = "[!]", rendered = " ", highlight = "DiagnosticWarn", scope_highlight = nil },
		},
	},
	code = {
		language_icon = false,
		width = "block",
		min_width = 80,
	},
	completions = { lsp = { enabled = true } },
	-- conceal = { level = 1 }, -- Disable conceal entirely
	dash = { enabled = false },
	file_types = { "markdown", "quarto", "codecompanion" },
	heading = {
		backgrounds = {},
		left_pad = 0,
		position = "inline",
		right_pad = 3,
		icons = {
			"# ",
			"## ",
			"### ",
			"#### ",
			"##### ",
			"###### ",
		},
	},
	html = {
		enabled = true,
		comment = { conceal = false },
	},
	pipe_table = {
		preset = "round",
	},
})

-- Todo-comments -----------------------------------
require("todo-comments").setup({})

-- Toggleterm -----------------------------------
require("toggleterm").setup({})

--- Treesitter -----------------------------------
require("nvim-treesitter.configs").setup({
	auto_install = true, -- Key for the `paq` approach to get parsers
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
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
})

--- WhichKey -----------------------------------
require("which-key").setup({
	preset = "classic",
	icons = {
		group = " ",
	},
})
-- add keymap groups
local wk = require("which-key")
wk.add({
	{ "<leader>a", group = "AI", icon = " " },
	{ "<leader>b", group = "Buffer", icon = " " },
	{ "<leader>c", group = "Code", icon = " " },
	{ "<leader>d", group = "Diagnostics/Debug", icon = " " },
	{ "<leader>e", group = "Explore", icon = " " },
	{ "<leader>f", group = "Files", icon = " " },
	{ "<leader>g", group = "Git", icon = " " },
	{ "<leader>h", group = "Help", icon = " " },
	{ "<leader>l", group = "LSP", icon = " " },
	{ "<leader>m", group = "Markdown", icon = " " },
	{ "<leader>o", group = "Obsidian", icon = "" },
	{ "<leader>q", group = "Quarto", icon = " " },
	{ "<leader>r", group = "Run", icon = " " },
	{ "<leader>s", group = "Search", icon = " " },
	{ "<leader>t", group = "Toggle", icon = " " },
	{ "<leader>w", proxy = "<C-w>", group = "Windows", icon = " " },
	{ "<leader>x", desc = "Quit", icon = " " },
})

-- Yazi -----------------------------------
require("yazi").setup({})

-- Diffview ----------------------------------
local actions = require("diffview.actions")
require("diffview").setup({
	keymaps = {
		disable_defaults = false,
	},
})
