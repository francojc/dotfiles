--| Markdown buffer-local settings ---------------------------
vim.opt_local.textwidth = 0
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true

--| CriticMarkup keymaps --------------------------------------
-- Wrap selection (or insert at cursor) with CriticMarkup markers.
-- See ../queries/markdown/highlights.scm for syntax highlighting.
-- See ../snippets/markdown.json for tab-completion snippets.
local function map(mode, lhs, rhs, opts)
	local options = vim.tbl_deep_extend("force", { silent = true, buffer = true }, opts or {})
	vim.keymap.set(mode, lhs, rhs, options)
end

--- Helpers ----------------------------------------------------
-- Visual: surround selection with left/right markers
local function surround_visual(left, right)
	return function()
		local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
		-- Save register contents we'll clobber
		vim.cmd('normal! gv')
		vim.cmd('normal! "_d')
		local saved = vim.fn.getreg('"')
		vim.fn.setreg('"', saved)
		-- Re-select
		vim.cmd('normal! gv')
		-- Yank selection
		vim.cmd('normal! y')
		local sel = vim.fn.getreg('"')
		-- Compose: left + sel + right
		local replacement = left .. sel .. right
		vim.cmd('normal! c' .. replacement)
	end
end

--- Surround keymaps (work in normal and visual mode) ----------
-- Insert: {++ ++}
map("v", "<leader>mi", surround_visual("{++", "++}"), { desc = "CriticMarkup: insert" })
-- Delete: {-- --}
map("v", "<leader>md", surround_visual("{--", "--}"), { desc = "CriticMarkup: delete" })
-- Highlight: {== ==}
map("v", "<leader>mh", surround_visual("{==", "==}"), { desc = "CriticMarkup: highlight" })
-- Comment: {>> <<}
map("v", "<leader>mc", surround_visual("{>>", "<<}"), { desc = "CriticMarkup: comment" })
-- Substitution: {~~old~>new~~}  (prompt for new text)
map("v", "<leader>ms", function()
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.cmd('normal! gv')
	vim.cmd('normal! y')
	local sel = vim.fn.getreg('"')
	vim.ui.input({ prompt = "Substitute with: " }, function(input)
		if input == nil then
			return
		end
		local replacement = "{~~" .. sel .. "~>" .. input .. "~~}"
		vim.cmd('normal! c' .. vim.api.nvim_replace_termcodes(replacement, true, false, true))
	end)
end, { desc = "CriticMarkup: substitute" })

--- Normal-mode insertions (insert markers at cursor) ---------
map("n", "<leader>mI", "a{++<++>++}<Esc>F+", { desc = "CriticMarkup: insert (empty)" })
map("n", "<leader>mD", "a{--<-->--}<Esc>F-", { desc = "CriticMarkup: delete (empty)" })
map("n", "<leader>mH", "a{==<==>==}<Esc>F=", { desc = "CriticMarkup: highlight (empty)" })
map("n", "<leader>mK", "a{>><<}><Esc>F>", { desc = "CriticMarkup: comment (empty)" })

--- Text objects -----------------------------------------------
-- Find the closest matching open/close pair around cursor and
-- select inner/around. Single-line only.
local function make_textobj(open_str, close_str)
	return function()
		local lnum = vim.api.nvim_get_current_line()
		local _, col = unpack(vim.api.nvim_win_get_cursor(0))
		-- Search backward from cursor for open_str
		local open_col = nil
		for i = col, #open_str, -1 do
			if i - #open_str + 1 >= 1 and lnum:sub(i - #open_str + 1, i) == open_str then
				-- Verify there's a matching close before any other open
				local rest = lnum:sub(i + 1)
				local close_idx = rest:find(close_str, 1, true)
				if close_idx then
					open_col = i - #open_str + 1
					break
				end
			end
		end
		if not open_col then
			-- Cancel any pending visual/operator
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
			return
		end
		-- Find close after open
		local rest = lnum:sub(open_col + #open_str)
		local close_rel = rest:find(close_str, 1, true)
		if not close_rel then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
			return
		end
		local close_col = open_col + #open_str + close_rel - 1
		-- Determine mode: 'x' (visual) or 'o' (operator-pending)
		local mode = vim.api.nvim_get_mode().mode
		local is_inner = mode:sub(1, 1) == "i"
		-- Position cursor on open delimiter (start) and enter visual
		vim.api.nvim_win_set_cursor(0, { vim.api.nvim_get_current_line(), open_col - 1 })
		vim.cmd("normal! v")
		-- Move to end of selection
		local end_col
		if is_inner then
			end_col = close_col - 1
		else
			end_col = close_col + #close_str - 1
		end
		vim.api.nvim_win_set_cursor(0, { vim.api.nvim_get_current_line(), end_col })
	end
end

-- Bind: text-object keys (work as xmap + omap)
-- ic/ac = comment, ih/ah = highlight, ii/ai = insert, id/ad = delete
-- ix/ax = substitution
for _, mode in ipairs({ "x", "o" }) do
	vim.keymap.set(mode, "ic", make_textobj("{>>", "<<}"), { buffer = true, silent = true, desc = "CriticMarkup: inner comment" })
	vim.keymap.set(mode, "ac", make_textobj("{>>", "<<}"), { buffer = true, silent = true, desc = "CriticMarkup: around comment" })
	vim.keymap.set(mode, "ih", make_textobj("{==", "==}"), { buffer = true, silent = true, desc = "CriticMarkup: inner highlight" })
	vim.keymap.set(mode, "ah", make_textobj("{==", "==}"), { buffer = true, silent = true, desc = "CriticMarkup: around highlight" })
	vim.keymap.set(mode, "ii", make_textobj("{++", "++}"), { buffer = true, silent = true, desc = "CriticMarkup: inner insert" })
	vim.keymap.set(mode, "ai", make_textobj("{++", "++}"), { buffer = true, silent = true, desc = "CriticMarkup: around insert" })
	vim.keymap.set(mode, "id", make_textobj("{--", "--}"), { buffer = true, silent = true, desc = "CriticMarkup: inner delete" })
	vim.keymap.set(mode, "ad", make_textobj("{--", "--}"), { buffer = true, silent = true, desc = "CriticMarkup: around delete" })
	vim.keymap.set(mode, "ix", make_textobj("{~~", "~~}"), { buffer = true, silent = true, desc = "CriticMarkup: inner substitution" })
	vim.keymap.set(mode, "ax", make_textobj("{~~", "~~}"), { buffer = true, silent = true, desc = "CriticMarkup: around substitution" })
end

--- User commands ---------------------------------------------
-- :CriticConvert [format]   - convert current MD to DOCX/PDF
vim.api.nvim_create_user_command("CriticConvert", function(opts)
	local fmt = opts.args ~= "" and opts.args or "docx"
	vim.cmd("write")
	local cmd = {
		"pandoc",
		vim.fn.expand("%"),
		"-f",
		"markdown-smart-strikeout-subscript-superscript-citations",
		"-o",
		vim.fn.expand("%:r") .. "." .. fmt,
		"--lua-filter=" .. vim.fn.stdpath("config") .. "/lua/core/critic.lua",
		"-M",
		"author=" .. (vim.g.critic_author or "Reviewer"),
		"-M",
		"date=" .. os.date("%Y-%m-%dT%H:%M:%SZ"),
	}
	vim.fn.system(cmd)
	if vim.v.shell_error == 0 then
		vim.notify("Converted to " .. vim.fn.expand("%:r") .. "." .. fmt, vim.log.levels.INFO)
	else
		vim.notify("Pandoc error:\n" .. vim.fn.systemlist(cmd)[1], vim.log.levels.ERROR)
	end
end, { nargs = "?", desc = "CriticMarkup: convert to DOCX/PDF (default: docx)" })

-- :CriticOpen  - open the last-converted DOCX
vim.api.nvim_create_user_command("CriticOpen", function()
	local docx = vim.fn.expand("%:r") .. ".docx"
	if vim.fn.filereadable(docx) == 1 then
		vim.fn.system("open " .. vim.fn.shellescape(docx))
		vim.notify("Opened " .. docx, vim.log.levels.INFO)
	else
		vim.notify("No DOCX found. Run :CriticConvert first.", vim.log.levels.WARN)
	end
end, { desc = "CriticMarkup: open last-converted DOCX" })
