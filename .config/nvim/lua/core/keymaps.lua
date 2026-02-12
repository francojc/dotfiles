--| Keymaps ------------------------------------------------------
local g = vim.g

-- Leader key -----
g.mapleader = " "
g.maplocalleader = " "

-- Load Copilot helper functions
require("copilot-helpers")

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
map("n", "<leader>x", ":wa<Bar>qa!<Cr>", { desc = "Save all and quit" })
-- Quit
-- Resize
map("n", "<leader>wk", "<C-w>10-", { desc = "Resize window up" })
map("n", "<leader>wj", "<C-w>10+", { desc = "Resize window down" })
map("n", "<leader>wh", "<C-w>10<", { desc = "Resize window left" })
map("n", "<leader>wl", "<C-w>10>", { desc = "Resize window right" })
-- Go to
-- Beginning of line
map({ "n", "v" }, "gh", "^", { desc = "Go to first character of line" })
-- End of line
map({ "n", "v" }, "gl", "g_", { desc = "Go to last character of line" })
map({ "n", "v" }, "go", "o<Esc>", { desc = "Add line below current line" })
map({ "n", "v" }, "gO", "O<Esc>", { desc = "Add line above current line" })
map("n", "gt", "<cmd>lua vim.lsp.buf.document_symbol()<cr>", { desc = "Show LSP document symbols" })
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
g.copilot_no_tab_map = true -- Disable default tab mapping
map("i", "<C-d>", "<Plug>(copilot-accept-word)", { desc = "Accept word" })
map("i", "<C-f>", "<Plug>(copilot-accept-line)", { desc = "Accept line" })
map("i", "<C-g>", "copilot#Accept('\\<Cr>')", { expr = true, replace_keycodes = false, desc = "Accept suggestion" })
map("i", "<C-n>", "<Plug>(copilot-next)", { desc = "Next suggestion" })
map("i", "<C-p>", "<Plug>(copilot-previous)", { desc = "Previous suggestion" })
map("i", "<C-e>", "<Plug>(copilot-dismiss)", { desc = "Dismiss suggestion" })

-- Buffers --------------------------
-- Buffer navigation (native commands)
map("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<Cmd>lua Close_other_buffers()<Cr>", { desc = "Close other buffers" })
map("n", "<leader>bf", "<Cmd>lua Snacks.picker.buffers()<Cr>", { desc = "Buffer find" })

-- Code -----------------------------
map("n", "<leader>ca", "<Cmd>lua Snacks.picker.lsp_code_actions()<Cr>", { desc = "Code actions" })
map(
	{ "n", "v" },
	"<leader>cf",
	"<Cmd>lua require('conform').format({lsp_format = 'fallback'})<Cr>",
	{ desc = "Code format" }
)
map("n", "<leader>cn", "<Cmd>s/\\s\\+/ /g<CR>", { desc = "Remove extra spaces (current line)" })
map("v", "<leader>cn", ":s/\\s\\+/ /g<CR>", { desc = "Remove extra spaces (selected lines)" })

-- AI Assistant (CopilotChat) -----------------------------
map("n", "<leader>aa", "<Cmd>CopilotChatToggle<Cr>", { desc = "AI Chat toggle" })
map("v", "<leader>aa", "<Cmd>CopilotChatToggle<Cr>", { desc = "AI Chat toggle" })
map("n", "<leader>ax", "<Cmd>CopilotChatClose<Cr>", { desc = "AI Chat close" })
map("n", "<leader>aR", "<Cmd>CopilotChatReset<Cr>", { desc = "AI Chat reset" })

map("n", "<leader>as", "<Cmd>CopilotChatStop<Cr>", { desc = "AI Chat stop" })
map("n", "<leader>ap", "<Cmd>CopilotChatPrompts<Cr>", { desc = "AI Chat prompts" })
map("n", "<leader>am", "<Cmd>CopilotChatModels<Cr>", { desc = "AI Chat models" })

-- Context-specific sends (token-efficient)
map("v", "<leader>av", ":CopilotChat #selection ", { desc = "AI Chat with selection" })
map("n", "<leader>al", ":CopilotChat #selection ", { desc = "AI Chat with current line" })
map("n", "<leader>ab", ":CopilotChat #buffer:active ", { desc = "AI Chat with active buffer" })
map("n", "<leader>ag", ":CopilotChat #gitdiff:staged ", { desc = "AI Chat with git diff" })
map("n", "<leader>aq", ":CopilotChat #quickfix ", { desc = "AI Chat with quickfix" })
map("n", "<leader>aw", ":CopilotChat #diagnostics ", { desc = "AI Chat with diagnostics" })

-- Quick prompts with context (visual mode)
map("v", "<leader>aE", ":CopilotChat #selection Explain this code<CR>", { desc = "AI Explain selection" })
map("v", "<leader>aF", ":CopilotChat #selection Fix any issues<CR>", { desc = "AI Fix selection" })
map("v", "<leader>aO", ":CopilotChat #selection Optimize this<CR>", { desc = "AI Optimize selection" })

-- Model preset management
map("n", "<leader>aM", "<Cmd>lua Copilot_toggle_model_preset()<Cr>", { desc = "AI Model presets" })
map("n", "<leader>aM1", "<Cmd>lua Copilot_set_model_preset('academic')<Cr>", { desc = "AI Academic mode" })
map("n", "<leader>aM2", "<Cmd>lua Copilot_set_model_preset('creative')<Cr>", { desc = "AI Creative mode" })
map("n", "<leader>aM3", "<Cmd>lua Copilot_set_model_preset('precise')<Cr>", { desc = "AI Precise mode" })
map("n", "<leader>aM4", "<Cmd>lua Copilot_set_model_preset('research')<Cr>", { desc = "AI Research mode" })
map("n", "<leader>aM5", "<Cmd>lua Copilot_set_model_preset('code')<Cr>", { desc = "AI Code mode" })

-- Diagnostics/Debug -----------------------------
map("n", "<leader>dd", "<Cmd>lua vim.diagnostic.open_float()<Cr>", { desc = "Show diagnostics" })
-- Neovim 0.12+: gf in diagnostic float jumps to related locations
map("n", "gf", "<Cmd>lua vim.diagnostic.goto_related()<Cr>", { desc = "Go to related diagnostic" })

-- Explore -------------------------------
-- Yazi
map("n", "<leader>ey", "<Cmd>Yazi<Cr>", { desc = "Yazi" })
map("n", "<leader>ec", "<Cmd>Yazi cwd<Cr>", { desc = "Yazi cwd" })
-- Files -----------------------------------
-- Snacks picker
map("n", "<leader><leader>", "<Cmd>lua Snacks.picker.smart()<Cr>", { desc = "Smart find files" })
map("n", "<leader>ff", "<Cmd>lua Snacks.picker.files()<Cr>", { desc = "Find files" })
map("n", "<leader>fg", "<Cmd>lua Snacks.picker.grep()<Cr>", { desc = "Live grep" })
map("n", "<leader>fn", "<Cmd>enew<Cr>", { desc = "New file" })
map("n", "<leader>fr", "<Cmd>lua Snacks.picker.recent()<Cr>", { desc = "Recent files" })
map("n", "<leader>fc", "<Cmd>lua Snacks.picker.resume()<Cr>", { desc = "Resume picker" })
-- Git -----------------------------------
-- Lazygit
map("n", "<leader>gg", "<Cmd>LazyGit<Cr>", { desc = "Lazygit" })
map("n", "<leader>gl", "<Cmd>LazyGitLog<Cr>", { desc = "Lazygit log" })
-- Diffview
map("n", "<leader>gd", "<Cmd>DiffviewOpen<Cr>", { desc = "Diff view (uncommitted)" })
map("n", "<leader>gh", "<Cmd>DiffviewFileHistory %<Cr>", { desc = "File history (current)" })
map("n", "<leader>gH", "<Cmd>DiffviewFileHistory<Cr>", { desc = "File history (repo)" })
map("n", "<leader>gx", "<Cmd>DiffviewClose<Cr>", { desc = "Close diff view" })
-- GitHub (Snacks gh)
map("n", "<leader>gio", "<Cmd>lua Snacks.picker.gh_issue({ state = 'open' })<Cr>", { desc = "GitHub issues (open)" })
map("n", "<leader>gpo", "<Cmd>lua Snacks.picker.gh_pr({ state = 'open' })<Cr>", { desc = "GitHub PRs (open)" })
-- GitHub create/open helpers
vim.keymap.set("n", "<leader>gic", function()
	vim.ui.input({ prompt = "Issue title: " }, function(title)
		if not title or title == "" then
			return
		end
		vim.ui.input({ prompt = "Body (optional): " }, function(body)
			local args = { "gh", "issue", "create", "-t", title }
			if body and body ~= "" then
				table.insert(args, "-b")
				table.insert(args, body)
			end
			vim.system(args, { text = true }, function(res)
				if res.code == 0 then
					vim.schedule(function()
						vim.notify("Issue created", vim.log.levels.INFO)
					end)
				else
					vim.schedule(function()
						vim.notify("gh issue create failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
					end)
				end
			end)
		end)
	end)
end, { desc = "GitHub: create issue" })

vim.keymap.set("n", "<leader>gpc", function()
	-- Create draft PR to base main using commit messages
	local args = { "gh", "pr", "create", "--draft", "--base", "main", "--fill" }
	vim.system(args, { text = true }, function(res)
		if res.code == 0 then
			vim.schedule(function()
				vim.notify("Draft PR created (base=main)", vim.log.levels.INFO)
			end)
		else
			vim.schedule(function()
				vim.notify("gh pr create failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
			end)
		end
	end)
end, { desc = "GitHub: create PR (draft, base=main)" })

vim.keymap.set("n", "<leader>gpC", function()
	-- Prompted PR creation
	local function notify(msg, level)
		vim.schedule(function()
			vim.notify(msg, level or vim.log.levels.INFO)
		end)
	end

	vim.ui.input({ prompt = "Base branch (default: main): " }, function(base)
		base = (base and base ~= "") and base or "main"
		vim.ui.select({ "Draft", "Normal" }, { prompt = "PR type:" }, function(kind)
			if not kind then
				return
			end
			local args = { "gh", "pr", "create", "--base", base }
			if kind == "Draft" then
				table.insert(args, "--draft")
			end
			vim.ui.select(
				{ "Use commit messages (--fill)", "Prompt for title/body" },
				{ prompt = "PR content:" },
				function(mode)
					if not mode then
						return
					end
					local function run()
						vim.system(args, { text = true }, function(res)
							if res.code == 0 then
								notify("PR created (base=" .. base .. ")")
							else
								notify("gh pr create failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
							end
						end)
					end

					if mode:find("fill", 1, true) then
						table.insert(args, "--fill")
						run()
					else
						vim.ui.input({ prompt = "Title: " }, function(title)
							if not title or title == "" then
								return
							end
							table.insert(args, "-t")
							table.insert(args, title)
							vim.ui.input({ prompt = "Body (optional): " }, function(body)
								if body and body ~= "" then
									table.insert(args, "-b")
									table.insert(args, body)
								end
								run()
							end)
						end)
					end
				end
			)
		end)
	end)
end, { desc = "GitHub: create PR (prompt)" })

-- LSP -----------------------------------
-- Navigation
map("n", "K", "<Cmd>lua vim.lsp.buf.hover()<Cr>", { desc = "Hover documentation" })
map("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<Cr>", { desc = "Go to declaration" })
map("n", "grt", "<Cmd>lua vim.lsp.buf.type_definition()<Cr>", { desc = "Go to type definition (0.12+)" })
map("n", "<leader>lD", "<Cmd>lua Snacks.picker.lsp_definitions()<Cr>", { desc = "Definitions" })
map("n", "<leader>lt", "<Cmd>lua Snacks.picker.lsp_type_definitions()<Cr>", { desc = "Type definitions" })
map("n", "<leader>li", "<Cmd>lua Snacks.picker.lsp_implementations()<Cr>", { desc = "Implementations" })
map("n", "<leader>lr", "<Cmd>lua Snacks.picker.lsp_references()<Cr>", { desc = "References" })
-- Incremental selection (Neovim 0.12+ LSP textDocument/selectionRange)
-- Uses integer direction: 0 (or omitted) = expand outward, -1 = shrink inward
-- Changed from 'an'/'in' to 'vn'/'vs' to avoid conflicting with 'a'/'i' insert mode keys
map({ "n", "v" }, "vn", "<Cmd>lua vim.lsp.buf.selection_range(0)<Cr>", { desc = "LSP: expand selection (next)" })
map({ "n", "v" }, "vs", "<Cmd>lua vim.lsp.buf.selection_range(-1)<Cr>", { desc = "LSP: shrink selection" })
-- Symbols
map("n", "<leader>ls", "<Cmd>lua Snacks.picker.lsp_symbols()<Cr>", { desc = "Document symbols" })
map("n", "<leader>lS", "<Cmd>lua Snacks.picker.lsp_workspace_symbols()<Cr>", { desc = "Workspace symbols" })
-- Actions
map("n", "<leader>ln", "<Cmd>lua vim.lsp.buf.rename()<Cr>", { desc = "Rename" })
map("n", "<leader>lh", "<Cmd>lua vim.lsp.buf.signature_help()<Cr>", { desc = "Signature help" })
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
map("v", "<leader>ml", '"aygv"_c[<C-r>a](<C-r>+)<Esc>', { desc = "Add link" })
-- Paste image
map(
	"n",
	"<leader>mp",
	"<Cmd>lua require('img-clip').paste_image({dir_path = 'images', relative_to_current_file = true })<Cr>",
	{ desc = "Paste image" }
)

-- Obsidian -----------------------------------
map("n", "<leader>oC", "<Cmd>Obsidian toc<Cr>", { desc = "Table of contents" })
map("n", "<leader>oD", "<Cmd>Obsidian dailies<Cr>", { desc = "Daily notes picker" })
map("n", "<leader>oL", "<Cmd>Obsidian links<Cr>", { desc = "Show all links in buffer" })
map("n", "<leader>oN", "<Cmd>Obsidian new_from_template<Cr>", { desc = "Create new note from template" })
map("n", "<leader>oT", "<Cmd>Obsidian tags<Cr>", { desc = "Search tags" })
map("n", "<leader>oT", "<Cmd>Obsidian template<Cr>", { desc = "Insert template" })
map("n", "<leader>ob", "<Cmd>Obsidian backlinks<Cr>", { desc = "Show backlinks" })
map("n", "<leader>oc", "<Cmd>Obsidian toggle_checkbox<Cr>", { desc = "Toggle checkbox" })
map("n", "<leader>od", "<Cmd>Obsidian today<Cr>", { desc = "Today's daily note" })
map("n", "<leader>of", "<Cmd>Obsidian follow_link<Cr>", { desc = "Follow link under cursor" })
map("n", "<leader>oi", "<Cmd>Obsidian paste_img<Cr>", { desc = "Paste image from clipboard" })
map("n", "<leader>on", "<Cmd>Obsidian new<Cr>", { desc = "Create new note" })
map("n", "<leader>oo", "<Cmd>Obsidian open<Cr>", { desc = "Open note in Obsidian app" })
map("n", "<leader>oq", "<Cmd>Obsidian quick_switch<Cr>", { desc = "Quick switch notes" })
map("n", "<leader>or", "<Cmd>Obsidian rename<Cr>", { desc = "Rename note" })
map("n", "<leader>os", "<Cmd>Obsidian search<Cr>", { desc = "Search notes" })
map("n", "<leader>ot", "<Cmd>Obsidian tomorrow<Cr>", { desc = "Tomorrow's daily note" })
map("n", "<leader>ow", "<Cmd>Obsidian workspace<Cr>", { desc = "Switch workspace" })
map("n", "<leader>oy", "<Cmd>Obsidian yesterday<Cr>", { desc = "Yesterday's daily note" })
map("v", "<leader>oL", "<Cmd>Obsidian link_new<Cr>", { desc = "Create new note from selection" })
map("v", "<leader>oe", "<Cmd>Obsidian extract_note<Cr>", { desc = "Extract selection to new note" })
map("v", "<leader>ol", "<Cmd>Obsidian link<Cr>", { desc = "Link selection to note" })

--- Session persistence -------------------------------
map("n", "<leader>ps", "<Cmd>lua Session_save_prompt()<Cr>", { desc = "Save session" })
map("n", "<leader>pl", "<Cmd>lua Session_load_last()<Cr>", { desc = "Load last session" })
map("n", "<leader>pS", "<Cmd>lua Session_select()<Cr>", { desc = "Select session" })

-- Quarto -----------------------------------
map("n", "<C-CR>", "<Cmd>QuartoSend<Cr>", { desc = "Quarto: send cell" })
map("n", "<leader>qa", "<Cmd>QuartoSendAbove<Cr>", { desc = "Quarto: send above" })
map("n", "<leader>qb", "<Cmd>QuartoSendBelow<Cr>", { desc = "Quarto: send below" })
map("n", "<leader>qf", "<Cmd>QuartoSendAll<Cr>", { desc = "Quarto: send file" })
-- Slime
g.slime_target = "tmux"
-- vim.b.slime_cell_delimiter = "```"
map("n", "<leader>ql", "<Plug>SlimeLineSend<Cr>", { desc = "Send line to Slime" })
map({ "n", "v" }, "<leader>qr", "<Plug>SlimeRegionSend<Cr>", { desc = "Send region to Slime" })

-- References -----------------------------------
-- Bibtex
-- Search -----------------------------------
map("n", "<leader>sh", "<Cmd>lua Snacks.picker.help()<Cr>", { desc = "Search help tags" })
map("n", "<leader>sj", "<Cmd>lua Snacks.picker.jumps()<Cr>", { desc = "Search jumps" })
map("n", "<leader>sk", "<Cmd>lua Snacks.picker.keymaps()<Cr>", { desc = "Search keymaps" })
map("n", "<leader>sm", "<Cmd>lua Snacks.picker.marks()<Cr>", { desc = "Search marks" })
map("n", "<leader>sn", "<Cmd>lua Snacks.picker.notifications()<Cr>", { desc = "Search notifications" })
map("n", "<leader>sq", "<Cmd>lua Snacks.picker.qflist()<Cr>", { desc = "Quickfix List" })
map("n", "<leader>sr", "<Cmd>lua Snacks.picker.registers()<Cr>", { desc = "Search registers" })
map("n", "<leader>ss", "<Cmd>lua Snacks.picker.spelling()<Cr>", { desc = "Spelling suggestions" })
map("n", "<leader>st", "<Cmd>lua Snacks.picker.todo_comments()<Cr>", { desc = "Search todos" })

-- Toggle ------------------------------------
map("n", "<leader>tR", "<Cmd>lua Toggle_citation_format()<CR>", { desc = "Toggle citation format (Pandoc/LaTeX)" })
map("n", "<leader>ta", "<Cmd>AerialToggle<CR>", { desc = "Toggle Aerial" })
map("n", "<leader>tb", "<Cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle line blame" })
map("n", "<leader>tc", "<Cmd>HighlightColors Toggle<CR>", { desc = "Toggle color highlights" })
map("n", "<leader>td", "<Cmd>Gitsigns toggle_word_diff<CR>", { desc = "Toggle word diff" })
map("n", "<leader>tf", "<Cmd>AerialNavToggle<CR>", { desc = "Toggle Aerial (floating)" })
map("n", "<leader>ti", "<Cmd>lua Toggle_image_rendering()<CR>", { desc = "Toggle image rendering" })
map("n", "<leader>tl", "<Cmd>SpellLang<Cr>", { desc = "Select spell language" })
map("n", "<leader>tm", "<Cmd>RenderMarkdown toggle<Cr>", { desc = "Toggle markdown rendering" })
map("n", "<leader>tr", "<Cmd>lua Toggle_r_language_server()<CR>", { desc = "Toggle R LSP" })
map("n", "<leader>ts", "<Cmd>lua Toggle_spell()<Cr>", { desc = "Toggle spell" })
map("n", "<leader>tv", "<Cmd>CsvViewToggle<Cr>", { desc = "Toggle CSV view" })
map("n", "<leader>tw", "<Cmd>lua Toggle_wrap()<Cr>", { desc = "Toggle word wrap" })

-- Update / Plugins ------------------------------------
map("n", "<leader>uc", ":PackCheck<Cr>", { desc = "Check for updates" })
map("n", "<leader>uu", ":PackUpdate<Cr>", { desc = "Update all plugins" })
map("n", "<leader>uU", ":PackUpdate!<Cr>", { desc = "Force update all plugins" })
map("n", "<leader>up", "<Cmd>lua _G.Pack_update_picker()<Cr>", { desc = "Update specific plugin" })
map("n", "<leader>us", ":PackStatus<Cr>", { desc = "Show plugin status" })
map("n", "<leader>uC", ":PackClean<Cr>", { desc = "Clean unused plugins" })
map("n", "<leader>uS", ":PackSync<Cr>", { desc = "Sync plugins" })
