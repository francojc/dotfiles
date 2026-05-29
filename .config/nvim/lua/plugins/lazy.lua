---| LAZY PLUGINS -----------------------------
-- General data-driven loaders. Each table entry = { plugin_name, setup_fn }.
-- Config runs at load time via :packadd. Two autocommands cover all cases.
-- packadd on an already-loaded plugin is a no-op, so shared plugins
-- (e.g. render-markdown used by both markdown and quarto) are safe to list twice.

local configured_plugins = {}

local function load(name, fn)
	vim.cmd("packadd " .. name)
	if fn and not configured_plugins[name] then
		fn()
		configured_plugins[name] = true
	end
end

local obsidian_workspaces = {
	{ name = "Notes", path = "~/Obsidian/Notes/" },
	{ name = "Personal", path = "~/Obsidian/Personal/" },
}

local function setup_obsidian()
	require("obsidian").setup({
		legacy_commands = false,
		ui = { enable = false },
		checkbox = {
			order = { " ", "x", "/", "-", ">", "~", "!", "?" },
		},
		note_id_func = function(id, dir)
			return id
		end,
		workspaces = obsidian_workspaces,
		daily_notes = {
			folder = "plan/daily/",
			template = "Daily.md",
			date_format = "%Y-%m-%d",
			alias_format = "%B %-d, %Y",
			workdays_only = false,
		},
		templates = {
			folder = "plan/templates/",
			date_format = "%B %-d, %Y",
			time_format = "%H:%M",
		},
		new_notes_location = "Inbox",
		attachments = { folder = "./" },
	})
end

local function cwd_in_obsidian_vault()
	return vim.fs.find(".obsidian", {
		path = vim.fn.getcwd(),
		upward = true,
		type = "directory",
	})[1] ~= nil
end

---| FileType-triggered plugins ----------------------------------

local ft_lazy = {
	markdown = {
		{
			"image.nvim",
			function()
				require("image").setup({
					processor = "magick_cli",
					integrations = {
						markdown = {
							clear_in_insert_mode = false,
							filetypes = { "markdown", "quarto" },
							only_render_image_at_cursor = false,
						},
					},
				})
				require("image").disable()
			end,
		},
		{
			"img-clip.nvim",
			function()
				require("img-clip").setup({
					default = {
						dir_path = "./images",
						relative_to_current_file = true,
						show_dir_path_in_prompt = true,
					},
				})
			end,
		},
		{
			"render-markdown.nvim",
			function()
				require("render-markdown").setup({
					latex = { enabled = false },
					bullet = {
						icons = { "■ ", "□ ", "▪ ", "▫ " },
						left_pad = 0,
						right_pad = 2,
					},
					checkbox = {
						unchecked = { icon = "□ ", highlight = "RenderMarkdownUnchecked" },
						checked = { icon = " ", highlight = "RenderMarkdownChecked" },
						custom = {
							waiting = {
								raw = "[?]",
								rendered = " ",
								highlight = "DiagnosticInfo",
								scope_highlight = nil,
							},
							stale = {
								raw = "[-]",
								rendered = " ",
								highlight = "DiagnosticInfo",
								scope_highlight = nil,
							},
							forward = {
								raw = "[>]",
								rendered = " ",
								highlight = "DiagnosticError",
								scope_highlight = nil,
							},
							progress = {
								raw = "[/]",
								rendered = " ",
								highlight = "DiagnosticWarn",
								scope_highlight = nil,
							},
							cancel = {
								raw = "[~]",
								rendered = " ",
								highlight = "DiagnosticError",
								scope_highlight = nil,
							},
							important = {
								raw = "[!]",
								rendered = " ",
								highlight = "DiagnosticWarn",
								scope_highlight = nil,
							},
						},
					},
					code = {
						sign = true,
						priority = nil,
						highlight = "RenderMarkdownSign",
						-- language_border = " ",
					},
					completions = {
						lsp = { enabled = true },
						blink = { enabled = true },
					},
					dash = { enabled = false },
					file_types = { "markdown", "quarto" },
					heading = {
						backgrounds = {},
						left_pad = 0,
						position = "inline",
						right_pad = 3,
						icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
					},
					html = {
						enabled = true,
						comment = { conceal = false },
					},
					pipe_table = {
						preset = "round",
					},
				})
			end,
		},
		{ "obsidian.nvim", setup_obsidian },
		{
			"snacks-bibtex.nvim",
			function()
				local cfg = require("snacks-bibtex.config").get()
				-- Disable default LaTeX commands, add Pandoc commands
				for _, cmd in ipairs(cfg.citation_commands) do
					cmd.enabled = false
				end
				local pandoc_citations = {
					{ cmd = "pandoc cite", template = "[@{{key}}]", desc = "Pandoc inline citation" },
					{ cmd = "pandoc in-text", template = "@{{key}}", desc = "Pandoc in-text author citation" },
					{
						cmd = "pandoc suppress author",
						template = "[-@{{key}}]",
						desc = "Pandoc citation (suppress author)",
					},
					{
						cmd = "pandoc with page",
						template = "[@{{key}}, p. ]",
						desc = "Pandoc citation with page locator",
					},
					{ cmd = "pandoc with prefix", template = "[see @{{key}}]", desc = "Pandoc citation with prefix" },
					{ cmd = "pandoc multiple", template = "[@{{key}}; @]", desc = "Pandoc multiple citations" },
				}
				for _, p in ipairs(pandoc_citations) do
					table.insert(cfg.citation_commands, {
						command = p.cmd,
						template = p.template,
						description = p.desc,
						packages = "pandoc",
						enabled = true,
					})
				end
				cfg.depth = 1
				cfg.format = "[@%s]"
				require("snacks-bibtex").setup(cfg)
			end,
		},
	},
	quarto = {
		{ "image.nvim", nil }, -- shared with markdown; packadd is a no-op if already loaded
		{ "img-clip.nvim", nil }, -- shared with markdown
		{ "render-markdown.nvim", nil }, -- shared with markdown
		{
			"otter.nvim",
			function()
				require("otter").setup({
					lsp = {
						diagnostic_update_events = { "BufWritePost" },
						root_dir = function(_, bufnr)
							return vim.fs.root(bufnr or 0, {
								".git",
								"_quarto.yml",
								"DESCRIPTION",
							}) or vim.fn.getcwd(0)
						end,
					},
					buffers = {
						set_filetype = true,
						write_to_disk = false,
					},
					handle_leading_whitespace = true,
				})
			end,
		},
		{
			"quarto-nvim",
			function()
				require("quarto").setup({
					lspFeatures = {
						enabled = true,
						chunks = "curly",
						languages = { "r", "python", "julia", "bash", "html" },
						diagnostics = {
							enabled = true,
							triggers = { "BufWritePost" },
						},
						completion = { enabled = true },
					},
					codeRunner = {
						enabled = true,
						default_method = "slime",
						never_run = { "yaml" },
					},
					keymap = false,
				})
			end,
		},
		{ "vim-slime", nil }, -- no setup needed
		{ "snacks-bibtex.nvim", nil }, -- shared with markdown
	},
	csv = {
		{
			"csvview.nvim",
			function()
				require("csvview").setup({})
			end,
		},
	},
	tsv = {
		{
			"csvview.nvim",
			function()
				require("csvview").setup({})
			end,
		},
	},
}

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("LazyFT", { clear = true }),
	pattern = vim.fn.keys(ft_lazy),
	callback = function(args)
		for _, spec in ipairs(ft_lazy[args.match] or {}) do
			load(spec[1], spec[2])
		end
		ft_lazy[args.match] = nil -- run once per filetype
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("LazyObsidianVault", { clear = true }),
	desc = "Load obsidian.nvim when Neovim starts inside an Obsidian vault",
	once = true,
	callback = function()
		if cwd_in_obsidian_vault() then
			load("obsidian.nvim", setup_obsidian)
		end
	end,
})

---| Command-triggered plugins ----------------------------------
-- NOTE: CmdUndefined fires when an unknown command is invoked. If another
-- plugin (or user config) defines the command before it's first called, this
-- autocommand will never fire for that command. Keep this in mind when
-- debugging lazy-load misses.

local cmd_lazy = {
	DiffviewOpen = {
		"diffview.nvim",
		function()
			require("diffview").setup({
				enhanced_diff_hl = true,
				view = {
					merge_tool = {
						layout = "diff3_horizontal",
						winbar_info = true,
					},
				},
			})
		end,
	},
	Quicker = {
		"quicker.nvim",
		function()
			require("quicker").setup({})
		end,
	},
	AerialToggle = {
		"aerial.nvim",
		function()
			require("aerial").setup({
				post_jump_cmd = "normal! zt",
			})
		end,
	},
	TodoTelescope = {
		"todo-comments.nvim",
		function()
			require("todo-comments").setup({})
		end,
	},
}

vim.api.nvim_create_autocmd("CmdUndefined", {
	group = vim.api.nvim_create_augroup("LazyCmd", { clear = true }),
	pattern = vim.fn.keys(cmd_lazy),
	callback = function(args)
		local spec = cmd_lazy[args.match]
		if spec then
			load(spec[1], spec[2])
		end
	end,
})

---| KEYMAPS FOR LAZY PLUGINS -----------------------------

-- BibTeX keymap (snacks-bibtex loads lazily via FileType; keymap registered eagerly)
vim.keymap.set("n", "<leader>rb", function()
	require("snacks-bibtex").bibtex()
end, { desc = "BibTeX citations" })

-- Toggle between Pandoc and LaTeX citation formats
_G.Toggle_citation_format = function()
	local ok, config_mod = pcall(require, "snacks-bibtex.config")
	if not ok then
		vim.notify("snacks-bibtex not loaded. Open a markdown or quarto file first.", vim.log.levels.WARN)
		return
	end
	local config = config_mod.get()
	local is_pandoc = vim.tbl_contains(
		vim.tbl_map(
			function(c)
				return c.command
			end,
			vim.tbl_filter(function(c)
				return c.enabled
			end, config.citation_commands)
		),
		"pandoc cite"
	)

	for _, cmd in ipairs(config.citation_commands) do
		cmd.enabled = cmd.command:match("^pandoc") and not is_pandoc or is_pandoc
	end

	require("snacks-bibtex").setup(config)
	vim.notify("Citation format: " .. (is_pandoc and "LaTeX" or "Pandoc"), vim.log.levels.INFO)
end
