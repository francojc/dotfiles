--| Markdown buffer-local settings ---------------------------
vim.opt_local.textwidth = 0
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true

--| CriticMarkup keymaps --------------------------------------
-- Wrap selection with CriticMarkup markers.
-- See ../queries/markdown/highlights.scm for syntax highlighting.
-- See ../snippets/markdown.json for tab-completion snippets.
local function map(mode, lhs, rhs, opts)
	local options = vim.tbl_deep_extend("force", { silent = true, buffer = true }, opts or {})
	vim.keymap.set(mode, lhs, rhs, options)
end

--- Helpers ----------------------------------------------------
local function visual_range()
	local mode = vim.api.nvim_get_mode().mode
	local start_row
	local start_col
	local end_row
	local end_col

	if mode:match("^[vV\22]") then
		local start_pos = vim.fn.getpos("v")
		local cursor = vim.api.nvim_win_get_cursor(0)
		start_row = start_pos[2] - 1
		start_col = start_pos[3] - 1
		end_row = cursor[1] - 1
		end_col = cursor[2] + 1
	else
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")
		start_row = start_pos[2] - 1
		start_col = start_pos[3] - 1
		end_row = end_pos[2] - 1
		end_col = end_pos[3]
	end

	if start_row > end_row or (start_row == end_row and start_col > end_col) then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col - 1, start_col + 1
	end

	return start_row, start_col, end_row, end_col
end

local function get_text(start_row, start_col, end_row, end_col)
	return table.concat(vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {}), "\n")
end

local function replace_text(start_row, start_col, end_row, end_col, text)
	vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, vim.split(text, "\n", { plain = true }))
end

-- Visual: surround selection with left/right markers
local function surround_visual(left, right)
	return function()
		local start_row, start_col, end_row, end_col = visual_range()
		local sel = get_text(start_row, start_col, end_row, end_col)
		replace_text(start_row, start_col, end_row, end_col, left .. sel .. right)
	end
end

--- Surround keymaps (visual mode) -----------------------------
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
	local start_row, start_col, end_row, end_col = visual_range()
	local sel = get_text(start_row, start_col, end_row, end_col)
	vim.ui.input({ prompt = "Substitute with: " }, function(input)
		if input == nil then
			return
		end
		replace_text(start_row, start_col, end_row, end_col, "{~~" .. sel .. "~>" .. input .. "~~}")
	end)
end, { desc = "CriticMarkup: substitute" })

--- Text objects -----------------------------------------------
-- Find closest matching open/close pair around cursor and select inner/around.
-- Single-line only.
local function find_pair(line, cursor_col, open_str, close_str)
	local cursor_idx = cursor_col + 1
	local best = nil
	local search_from = 1

	while true do
		local open_start, open_end = line:find(open_str, search_from, true)
		if not open_start or open_start > cursor_idx then
			break
		end
		local close_start, close_end = line:find(close_str, open_end + 1, true)
		if close_start and cursor_idx <= close_end then
			best = { open_start = open_start, open_end = open_end, close_start = close_start, close_end = close_end }
		end
		search_from = open_start + 1
	end

	return best
end

local function make_textobj(open_str, close_str, inner)
	return function()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local line = vim.api.nvim_get_current_line()
		local pair = find_pair(line, col, open_str, close_str)
		if not pair then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
			return
		end

		local start_col
		local end_col
		if inner then
			start_col = pair.open_end
			end_col = pair.close_start - 2
		else
			start_col = pair.open_start - 1
			end_col = pair.close_end - 1
		end

		if end_col < start_col then
			return
		end

		vim.api.nvim_win_set_cursor(0, { row, start_col })
		vim.cmd("normal! v")
		vim.api.nvim_win_set_cursor(0, { row, end_col })
	end
end

-- Bind: text-object keys (work as xmap + omap)
-- ic/ac = comment, ih/ah = highlight, ii/ai = insert, id/ad = delete
-- ix/ax = substitution
for _, mode in ipairs({ "x", "o" }) do
	vim.keymap.set(mode, "ic", make_textobj("{>>", "<<}", true), { buffer = true, silent = true, desc = "CriticMarkup: inner comment" })
	vim.keymap.set(mode, "ac", make_textobj("{>>", "<<}", false), { buffer = true, silent = true, desc = "CriticMarkup: around comment" })
	vim.keymap.set(mode, "ih", make_textobj("{==", "==}", true), { buffer = true, silent = true, desc = "CriticMarkup: inner highlight" })
	vim.keymap.set(mode, "ah", make_textobj("{==", "==}", false), { buffer = true, silent = true, desc = "CriticMarkup: around highlight" })
	vim.keymap.set(mode, "ii", make_textobj("{++", "++}", true), { buffer = true, silent = true, desc = "CriticMarkup: inner insert" })
	vim.keymap.set(mode, "ai", make_textobj("{++", "++}", false), { buffer = true, silent = true, desc = "CriticMarkup: around insert" })
	vim.keymap.set(mode, "id", make_textobj("{--", "--}", true), { buffer = true, silent = true, desc = "CriticMarkup: inner delete" })
	vim.keymap.set(mode, "ad", make_textobj("{--", "--}", false), { buffer = true, silent = true, desc = "CriticMarkup: around delete" })
	vim.keymap.set(mode, "ix", make_textobj("{~~", "~~}", true), { buffer = true, silent = true, desc = "CriticMarkup: inner substitution" })
	vim.keymap.set(mode, "ax", make_textobj("{~~", "~~}", false), { buffer = true, silent = true, desc = "CriticMarkup: around substitution" })
end

--- User commands ---------------------------------------------
-- :CriticConvert [format]   - convert current MD to DOCX/PDF
vim.api.nvim_create_user_command("CriticConvert", function(opts)
	local fmt = opts.args ~= "" and opts.args or "docx"
	local output = vim.fn.expand("%:r") .. "." .. fmt
	vim.cmd("write")
	local cmd = {
		"pandoc",
		vim.fn.expand("%"),
		"-f",
		"markdown-smart-strikeout-subscript-superscript-citations",
		"-t",
		fmt,
		"-o",
		output,
		"--lua-filter=" .. vim.fn.stdpath("config") .. "/lua/core/critic.lua",
		"-M",
		"author=" .. (vim.g.critic_author or "Reviewer"),
		"-M",
		"date=" .. os.date("!%Y-%m-%dT%H:%M:%SZ"),
	}
	local result = vim.system(cmd, { text = true }):wait()
	if result.code == 0 then
		vim.b.critic_last_output = output
		vim.notify("Converted to " .. output, vim.log.levels.INFO)
	else
		local msg = result.stderr ~= "" and result.stderr or result.stdout
		vim.notify("Pandoc error:\n" .. msg, vim.log.levels.ERROR)
	end
end, { nargs = "?", desc = "CriticMarkup: convert to DOCX/PDF (default: docx)" })

-- :CriticOpen  - open the last-converted DOCX
vim.api.nvim_create_user_command("CriticOpen", function()
	local docx = vim.b.critic_last_output or (vim.fn.expand("%:r") .. ".docx")
	if vim.fn.filereadable(docx) == 1 then
		if vim.ui.open then
			vim.ui.open(docx)
		else
			local opener = vim.fn.has("mac") == 1 and "open" or "xdg-open"
			vim.fn.system({ opener, docx })
		end
		vim.notify("Opened " .. docx, vim.log.levels.INFO)
	else
		vim.notify("No DOCX found. Run :CriticConvert first.", vim.log.levels.WARN)
	end
end, { desc = "CriticMarkup: open last-converted DOCX" })
