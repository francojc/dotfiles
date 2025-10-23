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
map("n", "<C-x>", ":qa!<Cr>", { desc = "Quit all, do not save" })
map("n", "<leader>x", ":qa!<Cr>", { desc = "Quit all, do not save" })
map("n", "<leader>wx", ":wa<Bar>qa!<Cr>", { desc = "Save all files and quit" })
-- Quit
-- Resize
map("n", "<leader>wk", "<C-w>10-", { desc = "Resize window up" })
map("n", "<leader>wj", "<C-w>10+", { desc = "Resize window down" })
map("n", "<leader>wh", "<C-w>10<", { desc = "Resize window left" })
map("n", "<leader>wl", "<C-w>10>", { desc = "Resize window right" })
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
-- INFO: this works, but there only seems to be one [model available](https://docs.github.com/en/copilot/concepts/completions/code-suggestions) 2025-07-01
g.copilot_settings = { selectedCompletionModel = "gpt-4.1-copilot" }

g.copilot_no_tab_map = true -- Disable default tab mapping
map("i", "<C-d>", "<Plug>(copilot-accept-word)", { desc = "Accept word" })
map("i", "<C-f>", "<Plug>(copilot-accept-line)", { desc = "Accept line" })
map("i", "<C-g>", "copilot#Accept('\\<Cr>')", { expr = true, replace_keycodes = false, desc = "Accept suggestion" })
map("i", "<C-n>", "<Plug>(copilot-next)", { desc = "Next suggestion" })
map("i", "<C-p>", "<Plug>(copilot-previous)", { desc = "Previous suggestion" })
map("i", "<C-e>", "<Plug>(copilot-dismiss)", { desc = "Dismiss suggestion" })

-- Assistant (Sidekick) --------------------------
-- NES (Next Edit Suggestions)
vim.keymap.set("n", "<leader>ae", function()
	require("sidekick.nes").enable()
end, { desc = "NES: enable" })

vim.keymap.set("n", "<leader>ad", function()
	require("sidekick.nes").disable()
end, { desc = "NES: disable" })

vim.keymap.set("n", "<leader>at", function()
	require("sidekick.nes").update()
end, { desc = "NES: trigger update" })

vim.keymap.set("n", "<leader>aa", function()
	require("sidekick.nes").apply()
end, { desc = "NES: apply suggestion" })

vim.keymap.set("n", "<leader>aj", function()
	if not require("sidekick").nes_jump_or_apply() then
		vim.notify("No more NES suggestions", vim.log.levels.INFO)
	end
end, { desc = "NES: jump to next or apply" })

-- CLI Terminal
vim.keymap.set("n", "<leader>ac", function()
	require("sidekick.cli").toggle()
end, { desc = "CLI: toggle terminal" })

vim.keymap.set({ "n", "v" }, "<leader>as", function()
	require("sidekick.cli").send({ msg = "{selection}" })
end, { desc = "CLI: send selection" })

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
map("n", "<leader>fg", "<Cmd>FzfLua live_grep<Cr>", { desc = "Live grep" })
map("n", "<leader>fn", "<Cmd>enew<Cr>", { desc = "New file" })
map("n", "<leader>fr", "<Cmd>FzfLua oldfiles<Cr>", { desc = "Recent files" })
map("n", "<leader>fc", "<Cmd>FzfLua resume<Cr>", { desc = "Resume fzf" })
-- Git -----------------------------------
-- Lazygit
map("n", "<leader>gg", "<Cmd>LazyGit<Cr>", { desc = "Lazygit" })
map("n", "<leader>gl", "<Cmd>LazyGitLog<Cr>", { desc = "Lazygit log" })
-- LSP -----------------------------------
-- Navigation
map("n", "K", "<Cmd>lua vim.lsp.buf.hover()<Cr>", { desc = "Hover documentation" })
map("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<Cr>", { desc = "Go to declaration" })
map("n", "<leader>lD", "<Cmd>FzfLua lsp_definitions<Cr>", { desc = "Definitions" })
map("n", "<leader>lt", "<Cmd>FzfLua lsp_typedefs<Cr>", { desc = "Type definitions" })
map("n", "<leader>li", "<Cmd>FzfLua lsp_implementations<Cr>", { desc = "Implementations" })
map("n", "<leader>lr", "<Cmd>FzfLua lsp_references<Cr>", { desc = "References" })
-- Symbols
map("n", "<leader>ls", "<Cmd>FzfLua lsp_document_symbols<Cr>", { desc = "Document symbols" })
map("n", "<leader>lS", "<Cmd>FzfLua lsp_workspace_symbols<Cr>", { desc = "Workspace symbols" })
-- Actions
map("n", "<leader>ln", "<Cmd>lua vim.lsp.buf.rename()<Cr>", { desc = "Rename" })
map("n", "<leader>lh", "<Cmd>lua vim.lsp.buf.signature_help()<Cr>", { desc = "Signature help" })
-- Call hierarchy
map("n", "<leader>lci", "<Cmd>FzfLua lsp_incoming_calls<Cr>", { desc = "Incoming calls" })
map("n", "<leader>lco", "<Cmd>FzfLua lsp_outgoing_calls<Cr>", { desc = "Outgoing calls" })
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
map("v", "<leader>mb", 'c**<C-r>"**<Esc>', { desc = "Bold" })
map("v", "<leader>mi", 'c*<C-r>"*<Esc>', { desc = "Italic" })
map("v", "<leader>ms", 'c~~<C-r>"~~<Esc>', { desc = "Strikethrough" })
-- Highlight (Pandoc mark ==…==)
map("v", "<leader>mh", 'c==<C-r>"==<Esc>', { desc = "Highlight (==mark==)" })
--- Code blocks
map("v", "<leader>mc", 'c```\n<C-r>"\n```<Esc>', { desc = "Code Block" })
map("v", "<leader>mC", 'c`<C-r>"`<Esc>', { desc = "Inline Code" })
-- Headings
map("n", "<leader>m1", "I# <Esc>", { desc = "Heading 1" })
map("n", "<leader>m2", "I## <Esc>", { desc = "Heading 2" })
map("n", "<leader>m3", "I### <Esc>", { desc = "Heading 3" })
map("n", "<leader>m4", "I#### <Esc>", { desc = "Heading 4" })
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
map("n", "<leader>oN", "<Cmd>Obsidian new_from_template<Cr>", { desc = "New from template" })
map("n", "<leader>ob", "<Cmd>Obsidian backlinks<Cr>", { desc = "Backlinks" })
map("n", "<leader>od", "<Cmd>Obsidian dailies<Cr>", { desc = "Daily note" })
map("n", "<leader>of", "<Cmd>Obsidian follow_link<Cr>", { desc = "Follow link" })
map("n", "<leader>oi", "<Cmd>Obsidian paste_img<Cr>", { desc = "Paste image" })
map("n", "<leader>ol", "<Cmd>Obsidian link_new<Cr>", { desc = "New link" })
map("n", "<leader>on", "<Cmd>Obsidian new<Cr>", { desc = "New note" })
map("n", "<leader>oq", "<Cmd>Obsidian quick_switch<Cr>", { desc = "Quick switch" })
map("n", "<leader>or", "<Cmd>Obsidian rename<Cr>", { desc = "Rename note" })
map("n", "<leader>os", "<Cmd>Obsidian search<Cr>", { desc = "Search" })
map("n", "<leader>ot", "<Cmd>Obsidian tomorrow<Cr>", { desc = "Tomorrow note" })
map("n", "<leader>ow", "<Cmd>Obsidian workspace<Cr>", { desc = "Select workspace" })

--- Session persistence -------------------------------
map("n", "<leader>ps", "<Cmd>lua Session_save_prompt()<Cr>", { desc = "Save session" })
map("n", "<leader>pl", "<Cmd>lua Session_load_last()<Cr>", { desc = "Load last session" })
map("n", "<leader>pS", "<Cmd>lua Session_select()<Cr>", { desc = "Select session" })

-- Quarto -----------------------------------
map("n", "<C-CR>", "<Cmd>QuartoSend<Cr>", { desc = "Quarto: send cell" })
map("n", "<leader>qa", "<Cmd>QuartoSendAbove<Cr>", { desc = "Quarto: send above" })
map("n", "<leader>qb", "<Cmd>QuartoSendBelow<Cr>", { desc = "Quarto: send below" })
map("n", "<leader>qf", "<Cmd>QuartoSendAll<Cr>", { desc = "Quarto: send file" })

-- Run -----------------------------------
-- Slime
g.slime_target = "tmux"

-- vim.b.slime_cell_delimiter = "```"
map("n", "<leader>rl", "<Plug>SlimeLineSend<Cr>", { desc = "Send line to Slime" })
map({ "n", "v" }, "<leader>rr", "<Plug>SlimeRegionSend<Cr>", { desc = "Send region to Slime" })

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
map("n", "<leader>tm", "<Cmd>RenderMarkdown toggle<Cr>", { desc = "Toggle markdown rendering" })
map("n", "<leader>tr", "<Cmd>lua Toggle_r_language_server()<CR>", { desc = "Toggle R LSP" }) -- Call the Lua function
map("n", "<leader>ts", "<Cmd>lua Toggle_spell()<Cr>", { desc = "Toggle spell" })
map("n", "<leader>tt", "<Cmd>ToggleTerm direction=float<Cr>", { desc = "Toggle terminal float" })
map("n", "<leader>tv", "<Cmd>CsvViewToggle<Cr>", { desc = "Toggle CSV view" })
map("n", "<leader>tw", "<Cmd>lua Toggle_wrap()<Cr>", { desc = "Toggle word wrap" })
