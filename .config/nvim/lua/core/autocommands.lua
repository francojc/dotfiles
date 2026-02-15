--| Autocommands -------------------------------------------------
local a = vim.api

-- Create an autocommand group
-- personal group
a.nvim_create_augroup("personal", { clear = true })

-- Remove trailing whitespace on save
a.nvim_create_autocmd("BufWritePre", {
	group = "personal",
	pattern = "*",
	callback = function()
		local pos = vim.api.nvim_win_get_cursor(0)
		vim.cmd([[%s/\s\+$//e]])
		vim.api.nvim_win_set_cursor(0, pos)
	end,
})

-- Highlight on yank
a.nvim_create_autocmd("TextYankPost", {
	group = "personal",
	pattern = "*",
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Ensure .qmd files are treated as markdown for navigation and features
a.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = "personal",
	pattern = "*.qmd",
	callback = function()
		-- Set filetype to quarto but ensure markdown features work
		vim.bo.filetype = "quarto"
		-- Enable markdown-like navigation
		vim.bo.define = "^\\s*#\\+\\s*"
	end,
})

-- Simple markdown/quarto heading navigation
a.nvim_create_autocmd("FileType", {
	group = "personal",
	pattern = { "markdown", "quarto" },
	callback = function()
		-- Basic ]] and [[ navigation for headings
		vim.keymap.set(
			"n",
			"]]",
			"/^#\\+\\s.*$<CR>:nohlsearch<CR>zt",
			{ buffer = true, silent = true, desc = "Next heading" }
		)
		vim.keymap.set(
			"n",
			"[[",
			"?^#\\+\\s.*$<CR>:nohlsearch<CR>zt",
			{ buffer = true, silent = true, desc = "Previous heading" }
		)
	end,
})

-- Slime cell delimiter for R, Quarto, Markdown
vim.api.nvim_create_autocmd("FileType", {
	-- limit to only certain filetypes
	pattern = { "r", "quarto", "markdown" },
	callback = function()
		vim.b.slime_cell_delimiter = "```"
	end,
})

-- Session management: auto-save on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		local session_dir = vim.fn.stdpath("state") .. "/sessions"
		if vim.fn.isdirectory(session_dir) == 0 then
			vim.fn.mkdir(session_dir, "p")
		end
		local target = session_dir .. "/last.vim"
		pcall(vim.cmd, "mksession! " .. vim.fn.fnameescape(target))
	end,
})

-- Spell language management
local function get_project_root()
	local current_file = vim.fn.expand("%:p")
	if current_file == "" then
		return nil
	end
	local path = vim.fn.fnamemodify(current_file, ":h")
	local prev = nil
	while path ~= "" and path ~= "/" do
		if path == prev then
			break
		end
		prev = path
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

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		-- Skip special buffers (picker, terminal, etc.)
		local buftype = vim.bo.buftype
		local bufname = vim.api.nvim_buf_get_name(0)

		-- Only run for normal file buffers
		if buftype == "" and bufname ~= "" and not bufname:match("^%s*$") and not bufname:match("^%w+://") then
			load_spell_lang()
		end
	end,
})

-- Disable blink.cmp in Snacks picker buffers
vim.api.nvim_create_autocmd("FileType", {
	group = "personal",
	pattern = "snacks_picker_input",
	callback = function()
		-- Disable blink.cmp for picker input buffers
		vim.b.blink_cmp_enabled = false
	end,
})

-- Spell language command
local function set_spell_lang(lang)
	local project_root = get_project_root()
	if not project_root then
		return
	end
	local spell_lang_file = project_root .. "/.nvim_spell_lang"
	vim.fn.writefile({ lang }, spell_lang_file)
	vim.opt_local.spelllang = lang
end

vim.api.nvim_create_user_command("SpellLang", function()
	vim.ui.select({ "en_us", "es" }, {
		prompt = "Select spell language:",
	}, function(choice)
		if choice then
			set_spell_lang(choice)
		end
	end)
end, {})

-- User command for updating plugins (workaround for vim.pack.update() display bug)
vim.api.nvim_create_user_command("PackUpdate", function(opts)
	local force = opts.bang
	_G.Pack_update_all(force)
end, { desc = "Update all plugins", bang = true })

-- Check for available updates
vim.api.nvim_create_user_command("PackCheck", function()
	_G.Pack_check_updates()
end, { desc = "Check for plugin updates" })

-- Update specific plugin
vim.api.nvim_create_user_command("PackUpdatePlugin", function(opts)
	if opts.args and opts.args ~= "" then
		local plugins = vim.pack.get()
		for _, plugin in ipairs(plugins) do
			if plugin.spec.name == opts.args or vim.fn.fnamemodify(plugin.path, ":t") == opts.args then
				_G.Pack_update_plugin(plugin.path)
				return
			end
		end
		vim.notify("Plugin not found: " .. opts.args, vim.log.levels.ERROR)
	else
		_G.Pack_update_picker()
	end
end, { desc = "Update specific plugin", nargs = "?" })

-- Clean unused plugins
vim.api.nvim_create_user_command("PackClean", function()
	_G.Pack_clean()
end, { desc = "Clean unused plugins" })

-- Sync plugins
vim.api.nvim_create_user_command("PackSync", function()
	_G.Pack_sync()
end, { desc = "Sync plugins (install + update + clean)" })

-- Show plugin status
vim.api.nvim_create_user_command("PackStatus", function()
	_G.Pack_status()
end, { desc = "Show plugin status" })

-- Git branch cache updates for statusline performance
-- Update cache on buffer enter, directory change, and focus gained
vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged", "FocusGained" }, {
	group = "personal",
	callback = function()
		-- Skip special buffers (terminal, picker, etc.)
		local buftype = vim.bo.buftype
		if buftype == "" then
			Update_git_branch_cache()
			Update_search_count_cache()
		end
	end,
})

-- Search count cache updates for statusline performance
-- Update cache when search commands complete or buffer enters
vim.api.nvim_create_autocmd({ "CmdlineLeave", "BufEnter" }, {
	group = "personal",
	callback = function()
		-- Skip special buffers (terminal, picker, etc.)
		local buftype = vim.bo.buftype
		if buftype == "" then
			-- Update search count when leaving command line or entering buffer
			-- Check if we just finished a search by looking at @/
			if vim.fn.getreg("/") ~= "" then
				Update_search_count_cache()
			end
		end
	end,
})

-- Check for plugin updates on startup (weekly)
vim.api.nvim_create_autocmd("VimEnter", {
	group = "personal",
	once = true,
	callback = function()
		vim.schedule(function()
			if _G.Should_check_for_updates() then
				_G.Pack_check_updates()
			end
		end)
	end,
})

-- Enhanced search navigation with automatic search count updates
vim.api.nvim_create_autocmd("BufEnter", {
	group = "personal",
	callback = function()
		-- Only set up mappings for normal file buffers
		local bufname = vim.api.nvim_buf_get_name(0)
		if vim.bo.buftype == "" and not bufname:match("^%w+://") then
			-- Set up enhanced search navigation that updates search count
			local opts = { buffer = true, silent = true, noremap = true }

			-- Override n and N to update search count after navigation
			vim.keymap.set("n", "n", function()
				vim.cmd("normal! n")
				-- Small delay to allow cursor to move, then update search count
				vim.defer_fn(function()
					if vim.o.hlsearch and vim.fn.getreg("/") ~= "" then
						Update_search_count_cache()
					end
				end, 10)
			end, opts)

			vim.keymap.set("n", "N", function()
				vim.cmd("normal! N")
				-- Small delay to allow cursor to move, then update search count
				vim.defer_fn(function()
					if vim.o.hlsearch and vim.fn.getreg("/") ~= "" then
						Update_search_count_cache()
					end
				end, 10)
			end, opts)
		end
	end,
})
