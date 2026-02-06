-- Keymaps for Neovim 0.11.x

local map = require("core.functions").map

-- Vim basics
map("i", "jj", "<Esc>", { desc = "Escape insert mode" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })
map("n", "<Esc>", "<Cmd>nohlsearch<Cr>")
map("n", "<C-s>", ":w<Cr>", { desc = "Save file" })
map("n", "<C-a>", ":wa<Cr>", { desc = "Save all files" })
map("n", "<C-x>", ":qa!<Cr>", { desc = "Quit all without saving" })
map("n", "<leader>x", ":wa<Bar>qa!<Cr>", { desc = "Save all and quit" })

-- Window management
map("n", "<leader>wk", "<C-w>10-", { desc = "Resize window up" })
map("n", "<leader>wj", "<C-w>10+", { desc = "Resize window down" })
map("n", "<leader>wh", "<C-w>10<", { desc = "Resize window left" })
map("n", "<leader>wl", "<C-w>10>", { desc = "Resize window right" })
map("n", "<C-h>", "<C-w>h", { desc = "Move to window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to window below" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to window above" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to window right" })

-- Navigation
map({ "n", "v" }, "gh", "^", { desc = "Go to first character of line" })
map({ "n", "v" }, "gl", "g_", { desc = "Go to last character of line" })
map({ "n", "v" }, "go", "o<Esc>", { desc = "Add line below current line" })
map({ "n", "v" }, "gO", "O<Esc>", { desc = "Add line above current line" })
map("n", "gt", "<cmd>lua vim.lsp.buf.document_symbol()<cr>", { desc = "Show LSP document symbols" })

-- Visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
map("v", "p", '"_dP', { desc = "Paste without overwriting register" })

-- Scrolling
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Previous search result" })
map("n", "j", "gj", { desc = "Next visual line" })
map("n", "k", "gk", { desc = "Previous visual line" })

-- Copilot
map("i", "<C-d>", "<Plug>(copilot-accept-word)", { desc = "Accept word" })
map("i", "<C-f>", "<Plug>(copilot-accept-line)", { desc = "Accept line" })
map("i", "<C-g>", "copilot#Accept('\\<Cr>')", { expr = true, replace_keycodes = false, desc = "Accept suggestion" })
map("i", "<C-n>", "<Plug>(copilot-next)", { desc = "Next suggestion" })
map("i", "<C-p>", "<Plug>(copilot-previous)", { desc = "Previous suggestion" })
map("i", "<C-e>", "<Plug>(copilot-dismiss)", { desc = "Dismiss suggestion" })

-- Buffers
map("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<Cmd>lua Close_other_buffers()<Cr>", { desc = "Close other buffers" })
map("n", "<leader>bf", "<Cmd>lua Snacks.picker.buffers()<Cr>", { desc = "Buffer find" })

-- Code
map(
	{ "n", "v" },
	"<leader>cf",
	"<Cmd>lua require('conform').format({lsp_format = 'fallback'})<Cr>",
	{ desc = "Format code" }
)
map("n", "<leader>cn", "<Cmd>s/\\s\\+/ /<CR>", { desc = "Remove extra spaces (line)" })
map("v", "<leader>cn", ":s/\\s\\+/ /<CR>", { desc = "Remove extra spaces (selection)" })

-- AI (CopilotChat)
map("n", "<leader>aa", "<Cmd>CopilotChatToggle<Cr>", { desc = "AI Chat toggle" })
map("v", "<leader>aa", "<Cmd>CopilotChatToggle<Cr>", { desc = "AI Chat toggle" })
map("n", "<leader>ax", "<Cmd>CopilotChatClose<Cr>", { desc = "AI Chat close" })
map("n", "<leader>aR", "<Cmd>CopilotChatReset<Cr>", { desc = "AI Chat reset" })
map("n", "<leader>as", "<Cmd>CopilotChatStop<Cr>", { desc = "AI Chat stop" })
map("n", "<leader>ap", "<Cmd>CopilotChatPrompts<Cr>", { desc = "AI Chat prompts" })
map("n", "<leader>am", "<Cmd>CopilotChatModels<Cr>", { desc = "AI Chat models" })
map("v", "<leader>av", ":CopilotChat #selection ", { desc = "AI Chat with selection" })
map("n", "<leader>al", ":CopilotChat #selection ", { desc = "AI Chat with current line" })
map("n", "<leader>ab", ":CopilotChat #buffer:active ", { desc = "AI Chat with active buffer" })
map("n", "<leader>ag", ":CopilotChat #gitdiff:staged ", { desc = "AI Chat with git diff" })
map("n", "<leader>aq", ":CopilotChat #quickfix ", { desc = "AI Chat with quickfix" })
map("n", "<leader>aw", ":CopilotChat #diagnostics ", { desc = "AI Chat with diagnostics" })
map("v", "<leader>aE", ":CopilotChat #selection Explain this code<CR>", { desc = "AI Explain selection" })
map("v", "<leader>aF", ":CopilotChat #selection Fix any issues<CR>", { desc = "AI Fix selection" })
map("v", "<leader>aO", ":CopilotChat #selection Optimize this<CR>", { desc = "AI Optimize selection" })
map("n", "<leader>aM", "<Cmd>lua Copilot_toggle_model_preset()<Cr>", { desc = "AI Model presets" })

-- Diagnostics (0.11-compatible)
map("n", "<leader>dd", "<Cmd>lua vim.diagnostic.open_float()<Cr>", { desc = "Show diagnostics" })

-- LSP
map("n", "K", "<Cmd>lua vim.lsp.buf.hover()<Cr>", { desc = "Hover documentation" })
map("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<Cr>", { desc = "Go to declaration" })
map("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<Cr>", { desc = "Go to definition" })
map("n", "gr", "<Cmd>lua vim.lsp.buf.references()<Cr>", { desc = "Go to references" })
map("n", "<leader>lD", "<Cmd>lua vim.lsp.buf.definition()<Cr>", { desc = "Definitions" })
map("n", "<leader>li", "<Cmd>lua vim.lsp.buf.implementation()<Cr>", { desc = "Implementations" })
map("n", "<leader>lr", "<Cmd>lua vim.lsp.buf.references()<Cr>", { desc = "References" })
map("n", "<leader>ls", "<Cmd>lua vim.lsp.buf.document_symbol()<Cr>", { desc = "Document symbols" })
map("n", "<leader>lS", "<Cmd>lua vim.lsp.buf.workspace_symbol()<Cr>", { desc = "Workspace symbols" })
map("n", "<leader>ln", "<Cmd>lua vim.lsp.buf.rename()<Cr>", { desc = "Rename" })
map("n", "<leader>lh", "<Cmd>lua vim.lsp.buf.signature_help()<Cr>", { desc = "Signature help" })
map("n", "<leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<Cr>", { desc = "Code actions" })

-- Explore
map("n", "<leader>ey", "<Cmd>Yazi<Cr>", { desc = "Yazi" })
map("n", "<leader>ec", "<Cmd>Yazi cwd<Cr>", { desc = "Yazi cwd" })

-- Files
map("n", "<leader><leader>", "<Cmd>lua Snacks.picker.files()<Cr>", { desc = "Find files" })
map("n", "<leader>ff", "<Cmd>lua Snacks.picker.files()<Cr>", { desc = "Find files" })
map("n", "<leader>fg", "<Cmd>lua Snacks.picker.grep()<Cr>", { desc = "Live grep" })
map("n", "<leader>fn", "<Cmd>enew<Cr>", { desc = "New file" })
map("n", "<leader>fr", "<Cmd>lua Snacks.picker.recent()<Cr>", { desc = "Recent files" })
map("n", "<leader>fc", "<Cmd>lua Snacks.picker.resume()<Cr>", { desc = "Resume picker" })

-- Git
map("n", "<leader>gg", "<Cmd>LazyGit<Cr>", { desc = "Lazygit" })
map("n", "<leader>gl", "<Cmd>LazyGitCurrentFile<Cr>", { desc = "Lazygit log" })
map("n", "<leader>tb", "<Cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle line blame" })
map("n", "<leader>td", "<Cmd>Gitsigns toggle_word_diff<CR>", { desc = "Toggle word diff" })

-- Markdown
map("n", "<leader>mu", "I- <Esc>", { desc = "Unordered list item" })
map("v", "<leader>mu", ":s/^/- /<CR>gv", { desc = "Unordered list item" })
map("n", "<leader>mo", "I1. <Esc>", { desc = "Ordered list item" })
map("v", "<leader>mo", ":s/^/1. /<CR>gv", { desc = "Ordered list item" })
map("n", "<leader>mt", "I- [ ] <Esc>", { desc = "Task list item" })
map("v", "<leader>mt", ":s/^/- [ ] /<CR>gv", { desc = "Task list item" })
map("v", "<leader>mb", 'c**<C-r>"**<Esc>', { desc = "Bold" })
map("v", "<leader>mi", 'c*<C-r>"*<Esc>', { desc = "Italic" })
map("v", "<leader>ms", 'c~~<C-r>"~~<Esc>', { desc = "Strikethrough" })
map("v", "<leader>mh", 'c==<C-r>"==<Esc>', { desc = "Highlight (==mark==)" })
map("v", "<leader>mc", 'c```\n<C-r>"\n```<Esc>', { desc = "Code Block" })
map("v", "<leader>mC", 'c`<C-r>"`<Esc>', { desc = "Inline Code" })
map("n", "<leader>m1", "I# <Esc>", { desc = "Heading 1" })
map("n", "<leader>m2", "I## <Esc>", { desc = "Heading 2" })
map("n", "<leader>m3", "I### <Esc>", { desc = "Heading 3" })
map("n", "<leader>m4", "I#### <Esc>", { desc = "Heading 4" })
map("v", "<leader>ml", '"aygv"_c[<C-r>a](<C-r>+)<Esc>', { desc = "Add link" })
map(
	"n",
	"<leader>mp",
	"<Cmd>lua require('img-clip').paste_image({dir_path = 'images', relative_to_current_file = true })<Cr>",
	{ desc = "Paste image" }
)

-- Obsidian
map("n", "<leader>oC", "<Cmd>Obsidian toc<Cr>", { desc = "Table of contents" })
map("n", "<leader>oD", "<Cmd>Obsidian dailies<Cr>", { desc = "Daily notes picker" })
map("n", "<leader>oL", "<Cmd>Obsidian links<Cr>", { desc = "Show all links in buffer" })
map("n", "<leader>oN", "<Cmd>Obsidian new_from_template<Cr>", { desc = "Create new note from template" })
map("n", "<leader>oT", "<Cmd>Obsidian tags<Cr>", { desc = "Search tags" })
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

-- Sessions
map("n", "<leader>ps", "<Cmd>lua Session_save_prompt()<Cr>", { desc = "Save session" })
map("n", "<leader>pl", "<Cmd>lua Session_load_last()<Cr>", { desc = "Load last session" })
map("n", "<leader>pS", "<Cmd>lua Session_select()<Cr>", { desc = "Select session" })

-- Quarto
map("n", "<C-CR>", "<Cmd>QuartoSend<Cr>", { desc = "Quarto: send cell" })
map("n", "<leader>qa", "<Cmd>QuartoSendAbove<Cr>", { desc = "Quarto: send above" })
map("n", "<leader>qb", "<Cmd>QuartoSendBelow<Cr>", { desc = "Quarto: send below" })
map("n", "<leader>qf", "<Cmd>QuartoSendAll<Cr>", { desc = "Quarto: send file" })
map("n", "<leader>ql", "<Plug>SlimeLineSend<Cr>", { desc = "Send line to Slime" })
map({ "n", "v" }, "<leader>qr", "<Plug>SlimeRegionSend<Cr>", { desc = "Send region to Slime" })

-- Search
map("n", "<leader>sh", "<Cmd>lua Snacks.picker.help()<Cr>", { desc = "Search help tags" })
map("n", "<leader>sk", "<Cmd>lua Snacks.picker.keymaps()<Cr>", { desc = "Search keymaps" })
map("n", "<leader>sm", "<Cmd>lua Snacks.picker.marks()<Cr>", { desc = "Search marks" })
map("n", "<leader>sq", "<Cmd>lua Snacks.picker.qflist()<Cr>", { desc = "Quickfix List" })
map("n", "<leader>ss", "<Cmd>lua Snacks.picker.spelling()<Cr>", { desc = "Spelling suggestions" })
map("n", "<leader>st", "<Cmd>lua Snacks.picker.todo_comments()<Cr>", { desc = "Search todos" })

-- Toggle
map("n", "<leader>tR", "<Cmd>lua Toggle_citation_format()<CR>", { desc = "Toggle citation format" })
map("n", "<leader>ta", "<Cmd>AerialToggle<CR>", { desc = "Toggle Aerial" })
map("n", "<leader>tc", "<Cmd>HighlightColors Toggle<CR>", { desc = "Toggle color highlights" })
map("n", "<leader>tf", "<Cmd>AerialNavToggle<CR>", { desc = "Toggle Aerial (floating)" })
map("n", "<leader>ti", "<Cmd>lua Toggle_image_rendering()<CR>", { desc = "Toggle image rendering" })
map("n", "<leader>tm", "<Cmd>RenderMarkdown toggle<Cr>", { desc = "Toggle markdown rendering" })
map("n", "<leader>tr", "<Cmd>lua Toggle_r_language_server()<CR>", { desc = "Toggle R LSP" })
map("n", "<leader>ts", "<Cmd>lua Toggle_spell()<Cr>", { desc = "Toggle spell" })
map("n", "<leader>tv", "<Cmd>CsvViewToggle<Cr>", { desc = "Toggle CSV view" })
map("n", "<leader>tw", "<Cmd>lua Toggle_wrap()<Cr>", { desc = "Toggle word wrap" })
