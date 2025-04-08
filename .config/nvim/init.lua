--| Paq: plugins -------------------------------------------------
require("paq")({
  "akinsho/bufferline.nvim", -- Bufferline
  "akinsho/toggleterm.nvim", -- Toggle terminal
  "jmbuhr/otter.nvim", -- Otter for Quarto
  "nvim-lua/plenary.nvim", -- Plenary for Lua functions 
  "echasnovski/mini.icons", -- Icons
  "echasnovski/mini.indentscope", -- Indent guides
  "echasnovski/mini.pairs", -- Pairs
  "echasnovski/mini.statusline", -- Statusline
  "echasnovski/mini.surround", -- Surround
  "ellisonleao/gruvbox.nvim", -- Colorscheme: Gruvbox
  "epwalsh/obsidian.nvim", -- Obsidian integration
  "folke/flash.nvim", -- Flash jump
  "folke/todo-comments.nvim", -- Todo comments highlighting/searching
  "folke/which-key.nvim", -- Keymaps popup
  "github/copilot.vim", -- Copilot
  "ibhagwan/fzf-lua", -- FZF
  "hakonharnes/img-clip.nvim", -- Image pasting
  "jpalardy/vim-slime", -- Slime integration
  "kdheepak/lazygit.nvim", -- Lazygit integration
  "mikavilpas/yazi.nvim", -- Yazi file manager integration
  "neovim/nvim-lspconfig", -- LSP
  "olimorris/codecompanion.nvim", -- Code companion AI integration
  "nvim-neo-tree/neo-tree.nvim", -- File explorer
  "nvim-treesitter/nvim-treesitter", -- Treesitter
  "quarto-dev/quarto-nvim", -- Quarto integration
  "savq/paq-nvim", -- Paq manages itself
  "stevearc/aerial.nvim", -- Code outline
  "stevearc/conform.nvim", -- Formatter
  "vague2k/vague.nvim", -- Colorscheme: Vague
})

--| Options ------------------------------------------------------
local a = vim.api
local opt = vim.opt
local vim = vim

-- Globals -----
-- Record start time for startup duration
_G.nvim_config_start_time = vim.loop.hrtime()

-- Locals -----
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
-- Misc
opt.winborder = "rounded"
opt.showmode = false
opt.cmdheight = 0
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
-- Hide highlights
map("n", "<Esc>", "<Esc><Cmd>nohlsearch<Cr>")
-- Save file
map("n", "<C-s>", ":w<Cr>", { desc = "Save file" })
map("n", "<C-a>", ":wa<Cr>", { desc = "Save all files" })
-- Quit
map("n", "<leader>x", ":qa<Cr>", { desc = "Quit all" })
--- Window  -----
-- Move between editor/terminal windows
map({ "n", "t" }, "<C-h>", "<Cmd>wincmd h<Cr>", { desc = "Move to left window" })
map({ "n", "t" }, "<C-j>", "<Cmd>wincmd j<Cr>", { desc = "Move to bottom window" })
map({ "n", "t" }, "<C-k>", "<Cmd>wincmd k<Cr>", { desc = "Move to top window" })
map({ "n", "t" }, "<C-l>", "<Cmd>wincmd l<Cr>", { desc = "Move to right window" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })
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
-- AI ----------------------------
-- Copilot
map("i", "<C-d>", "<Plug>(copilot-accept-word)", { desc = "Accept word" })
map("i", "<C-f>", "<Plug>(copilot-accept-line)", { desc = "Accept line" })
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
map({ "n", "v" }, "<leader>cf", "<Cmd>lua require('conform').format()<Cr>", { desc = "Format file" })
map({ "n", "v" }, "<leader>cn", "<Cmd>s/\\s\\+/ /g<Cr>", { desc = "Remove extra spaces" })

-- Diagnostics/Debug -----------------------------
--
map("n", "<leader>dd", "<Cmd>lua vim.diagnostic.open_float()<Cr>", { desc = "Show diagnostics" })

-- Explore -------------------------------
-- Neotree
map("n", "<leader>ee", "<Cmd>Neotree toggle<Cr>", { desc = "Toggle Neotree" })
map("n", "<leader>ef", "<Cmd>Neotree float<Cr>", { desc = "Float Neotree" })
-- Yazi
map("n", "<leader>ey", "<Cmd>Yazi<Cr>", { desc = "Yazi" })
map("n", "<leader>ec", "<Cmd>Yazi cwd<Cr>", { desc = "Yazi cwd" })
-- Find -----------------------------------
-- Fzf-lua
map("n", "<leader>ff", "<Cmd>FzfLua files<Cr>", { desc = "Find files" })
map("n", "<leader>fg", "<Cmd>FzfLua live_grep resume=true<Cr>", { desc = "Live grep" })
map("n", "<leader>fr", "<Cmd>FzfLua oldfiles cwd=./<Cr>", { desc = "Recent files" })
map("n", "<leader>fc", "<Cmd>FzfLua resume<Cr>", { desc = "Resume fzf" })
-- Git -----------------------------------
-- Lazygit
map("n", "<leader>gg", "<Cmd>LazyGit<Cr>", { desc = "Lazygit" })
map("n", "<leader>gl", "<Cmd>LazyGitLog<Cr>", { desc = "Lazygit log" })
-- LSP -----------------------------------
map("n", "<leader>ls", "<Cmd>FzfLua lsp_document_symbols<Cr>", { desc = "Document symbols" })
map("n", "<leader>lS", "<Cmd>FzfLua lsp_workspace_symbols<Cr>", { desc = "Workspace symbols" })
map("n", "<leader>lD", "<Cmd>FzfLua lsp_definitions<Cr>", { desc = "Definitions" })
map("n", "<leader>lr", "<Cmd>FzfLua lsp_references<Cr>", { desc = "References" })
-- Markdown -----------------------------------
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
map("v", "<leader>ml", 'c[<C-r>"](<Esc>i)', { desc = "Add link" })
-- Paste image
map(
  "n",
  "<leader>mp",
  "<Cmd>lua require('img-clip').paste_image({dir_path = 'images', relative_to_current_file = true })<Cr>",
  { desc = "Paste image" }
)
-- Obsidian -----------------------------------
map("n", "<leader>od", "<Cmd>ObsidianDailies<Cr>", { desc = "Daily note" })
map("n", "<leader>on", "<Cmd>ObsidianNew<Cr>", { desc = "New note" })
map("n", "<leader>oN", "<Cmd>ObsidianNewFromTemplate<Cr>", { desc = "New from template" })
map("n", "<leader>oi", "<Cmd>ObsidianPasteImg<Cr>", { desc = "Paste image" })
map("n", "<leader>ol", "<Cmd>ObsidianLinkNew<Cr>", { desc = "New link" })
map("n", "<leader>of", "<Cmd>ObsidianFollowLink<Cr>", { desc = "Follow link" })
map("n", "<leader>or", "<Cmd>ObsidianRename<Cr>", { desc = "Rename note" })
map("n", "<leader>oc", "<Cmd>ObsidianToggleCheckbox<Cr>", { desc = "Toggle checkbox" })
-- Quarto -----------------------------------
map("n", "<C-CR>", "<Cmd>QuartoSend<Cr>", { desc = "Quarto: send cell" })
map("n", "<leader>qa", "<Cmd>QuartoSendAbove<Cr>", { desc = "Quarto: send above" })
map("n", "<leader>qb", "<Cmd>QuartoSendBelow<Cr>", { desc = "Quarto: send below" })
map("n", "<leader>qf", "<Cmd>QuartoSendAll<Cr>", { desc = "Quarto: send file" })

-- Run -----------------------------------
-- Slime
g.slime_target = "neovim"
vim.b.slime_cell_delimiter = "```"
map("n", "<leader>rl", "<Plug>SlimeLineSend<Cr>", { desc = "Send line to Slime" })
map("n", "<leader>rr", "<Plug>SlimeRegionSend<Cr>", { desc = "Send region to Slime" })
map("v", "<leader>rr", "<Plug>SlimeRegionSend<Cr>", { desc = "Send region to Slime" })

-- Search -----------------------------------
map("n", "<leader>st", "<Cmd>TodoFzfLua<Cr>", { desc = "Search todos" })
map("n", "<leader>sh", "<Cmd>FzfLua helptags<Cr>", { desc = "Search help tags" })
map("n", "<leader>sk", "<Cmd>FzfLua keymaps<Cr>", { desc = "Search keymaps" })
map("n", "<leader>ss", "<Cmd>FzfLua spell_suggest<Cr>", { desc = "Spelling suggestions" })
map("n", "<leader>sr", "<Cmd>FzfLua registers<Cr>", { desc = "Search registers" })

-- Flash search
map({ "n", "x", "o" }, "s", "<Cmd>lua require('flash').jump()<Cr>", { desc = "Flash" })
map({ "n", "x", "o" }, "S", "<Cmd>lua require('flash').treesitter()<Cr>", { desc = "Flash treesitter" })

-- Toggle ------------------------------------
map("n", "<leader>ta", "<Cmd>AerialToggle!<Cr>", { desc = "Toggle aerial" })
map("n", "<C-t>", "<Cmd>ToggleTerm direction=horizontal size=20<Cr>", { desc = "Toggle terminal" })
map("n", "<leader>tt", "<Cmd>ToggleTerm direction=float<Cr>", { desc = "Toggle terminal float" })
map("n", "<leader>tl", "<Cmd>SpellLang<Cr>", { desc = "Select spell language" })
map("n", "<leader>ts", "<Cmd>set spell!<Cr>", { desc = "Toggle spell" })
map("n", "<leader>tf", "<Cmd>lua require('flash').toggle()<Cr>", { desc = "Toggle flash" })

---| Functions ----------------------------------------------------
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
require("aerial").setup({})

-- Bufferline ----------------------------------
require("bufferline").setup({})

-- CodeCompanion ----------------------------------
require("codecompanion").setup({})

-- Colorscheme ----------------------------------
-- Gruvbox
require("gruvbox").setup({
  invert_selection = true,
  contrast = "hard",
  overrides = {},
})
-- Vague
require("vague").setup({})
-- Set colorscheme
vim.cmd("colorscheme gruvbox")

-- Conform ----------------------------------
require("conform").setup({})

-- Flash ----------------------------------
require("flash").setup({})

-- FZF ----------------------------------
require("fzf-lua").setup({})

-- Img-Clip ----------------------------------
require("img-clip").setup({})

-- -- Lazygit ----------------------------------
-- require("lazygit").setup({})

-- Mini -----------------------------------
require("mini.icons").setup({})
require("mini.pairs").setup({})
require("mini.indentscope").setup({})
require("mini.statusline").setup({})
require("mini.surround").setup({})

-- Neo-tree -----------------------------------
require("neo-tree").setup({})

-- Obsidian -----------------------------------
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

-- Quarto -----------------------------------
require("quarto").setup({})

-- Todo-comments -----------------------------------
require("todo-comments").setup({})

-- Toggleterm -----------------------------------
require("toggleterm").setup({})

--- Treesitter -----------------------------------
--- register quarto as markdown
vim.treesitter.language.register("markdown", "quarto")

-- setup
require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})

--- WhichKey -----------------------------------
--- setup
require("which-key").setup({
  preset = "helix",
  icons = {
    group = " ",
  },
})
-- add keymap groups
local wk = require("which-key")
wk.add({
  { "<leader>a", group = "AI", icon = " " }, -- Added AI group for consistency
  { "<leader>b", group = "Buffer", icon = " " },
  { "<leader>c", group = "Code", icon = " " }, -- Added Code group for consistency
  { "<leader>d", group = "Diagnostics/Debug", icon = " " }, -- Added Diagnostics group
  { "<leader>e", group = "Explore", icon = " " },
  { "<leader>f", group = "Find", icon = " " },
  { "<leader>g", group = "Git", icon = " " },
  { "<leader>h", group = "Help", icon = " " },
  { "<leader>l", group = "LSP", icon = " " },
  { "<leader>m", group = "Markdown", icon = " " },
  { "<leader>o", group = "Obsidian", icon = "" },
  { "<leader>q", group = "Quarto", icon = " " },
  { "<leader>r", group = "Run", icon = " " }, -- Added Run group for Slime
  { "<leader>s", group = "Search", icon = " " },
  { "<leader>t", group = "Toggle", icon = " " },
  { "<leader>w", proxy = "<C-w>", group = "Windows", icon = " " },
  { "<leader>x", desc = "Quit all", icon = " " }, -- Added Quit description
})

-- Yazi -----------------------------------
require("yazi").setup({})

