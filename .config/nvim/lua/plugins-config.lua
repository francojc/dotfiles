---| PLUGINS CONFIGURATION -----------------------------

---| UPFRONT ------------------------------------------
-- Load theme config early for colors used by plugins
local theme_config = require("theme-config")

---=====================================================
---==== EAGER PLUGINS ====---
---=====================================================

---=====================================================
---| COMPLETION & SNIPPETS
---=====================================================

---| Blink.cmp ----------------------------------
require("blink.cmp").setup({
	fuzzy = {
		implementation = "lua",
	},
	snippets = {
		expand = function(snippet)
			vim.snippet.expand(snippet)
		end,
	},
	completion = {
		list = {
			selection = {
				preselect = false,
				auto_insert = false,
			},
		},
		menu = {
			auto_show = true,
			auto_show_delay_ms = 1000,
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
			markdown = { "path", "snippets", "lsp", "emoji" },
			quarto = { "path", "snippets", "lsp", "emoji" },
		},
		providers = {
			snippets = {
				name = "snippets",
				module = "blink.cmp.sources.snippets",
				opts = {
					friendly_snippets = true,
					search_paths = { vim.fn.stdpath("config") .. "/snippets" },
				},
			},
			emoji = {
				name = "Emoji",
				module = "blink-emoji",
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

---============================================================
---| COLORSCHEMES & THEMING
---============================================================

---| Arthur ----------------------------------
-- (No setup required)

---| Autumn ----------------------------------
-- (No setup required)

---| Black Metal ----------------------------------
require("black-metal").setup({
	diagnostics = {
		darker = false,
	},
})

---| Catppuccin ----------------------------------
require("catppuccin").setup({
	flavour = "mocha", -- latte, frappe, macchiato, mocha
	background = { -- :h background
		light = "latte",
		dark = "mocha",
	},
	transparent_background = false,
	show_end_of_buffer = false,
	term_colors = false,
	compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
	styles = {
		comments = { "italic" },
		conditionals = { "italic" },
		loops = {},
		functions = {},
		keywords = {},
		strings = {},
		variables = {},
		numbers = {},
		booleans = {},
		properties = {},
		types = {},
		operators = {},
	},
	integrations = {
		treesitter = true,
		native_lsp = {
			enabled = true,
			virtual_text = {
				errors = { "italic" },
				hints = { "italic" },
				warnings = { "italic" },
				information = { "italic" },
			},
			underlines = {
				errors = { "underline" },
				hints = { "underline" },
				warnings = { "underline" },
				information = { "underline" },
			},
			inlay_hints = {
				background = true,
			},
		},
	},
})

---| Gruvbox ----------------------------------
require("gruvbox").setup({
	invert_selection = true,
	contrast = "hard",
	overrides = {},
})

--| Kanso ------------------------------------
require("kanso").setup({
	backround = {
		dark = "zen",
	},
	foreground = "saturated",
})

---| Nightfox ----------------------------------
require("nightfox").setup({
	styles = {
		comments = "italic",
		keywords = "bold",
		functions = "bold",
	},
})

---| OneDark ----------------------------------
require("onedark").setup({
	style = "darker",
})

---| Tokyo Night ----------------------------------
require("tokyonight").setup({
	style = "storm",
	light_style = "day",
	transparent = false,
	terminal_colors = true,
	styles = {
		comments = { italic = true },
		keywords = { italic = true },
		functions = {},
		variables = {},
		sidebars = "dark",
		floats = "dark",
	},
	sidebars = { "qf", "help" },
	day_brightness = 0.3,
	hide_inactive_statusline = false,
	dim_inactive = false,
})

---| Vague ----------------------------------
require("vague").setup({})

---| VS Code ----------------------------------
require("vscode").setup({
	style = "dark",
	transparent = false,
	italic_comments = false,
	disable_nvimtree_bg = true,
	color_overrides = {
		vscLineNumber = "#FFFFFF",
	},
	group_overrides = {
		Comment = { fg = "#FF0000", bg = "#0000FF", italic = true },
	},
})

---| Activate Colorscheme ----------------------------------
if theme_config.colorscheme == "ayu" then
	vim.g.ayucolor = "mirage" -- set ayu theme to mirage
end

vim.cmd("colorscheme " .. theme_config.colorscheme)

---| llama.vim Highlight Overrides ----------------------------------
vim.api.nvim_set_hl(0, "llama_hl_fim_hint", { fg = "#918374", ctermfg = 59 })
vim.api.nvim_set_hl(0, "llama_hl_fim_info", { fg = "#B9BB25", ctermfg = 119 })

-- Fix undercurl leak in tmux: use underline instead for URL highlights
vim.api.nvim_set_hl(0, "@string.special.url", { fg = "#7FB4CA", underline = true, undercurl = false })
vim.api.nvim_set_hl(0, "@markup.link.url", { link = "@string.special.url" })

---| Neovim 0.12+ Highlight Groups ----------------------------------
vim.api.nvim_set_hl(0, "DiffTextAdd", { bg = "#3d5213", fg = "#b4fa72" })

---============================================================
---| CODE FORMATTING
---============================================================

---| Conform ----------------------------------------
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
		quarto = { "injected" },
		r = { "air" },
		["*"] = { "trim_whitespace" },
	},
	formatters = {
		injected = {
			options = {
				ignore_errors = false,
				lang_to_ext = {
					bash = "sh",
					python = "py",
					r = "r",
					typst = "typ",
				},
			},
		},
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

---===========================================================
---| LANGUAGE SERVERS (LSP)
---===========================================================
-- Get enhanced LSP capabilities from blink.cmp
local capabilities = require("blink.cmp").get_lsp_capabilities()

---| Shell & System ----------------------------------

-- Bash (bash-language-server)
vim.lsp.config.bashls = {
	capabilities = capabilities,
	filetypes = { "sh", "bash" },
}

--| Go language server
-- Go (gopls)
vim.lsp.config.gopls = {
	cmd = { "gopls" },
	capabilities = capabilities,
	filetypes = { "go" },
	root_markers = { "go.mod", ".git" },
	settings = {},
}

-- Go (golangci-lint-langserver)
vim.lsp.config.golangci_lint_ls = {
	cmd = { "golangci-lint-langserver" },
	capabilities = capabilities,
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	init_options = {
		command = { "golangci-lint-langserver", "run", "--output.json.path=stdout", "--show-stats=false" },
	},
	root_markers = {
		".golangci.yml",
		".golangci.yaml",
		".golangci.toml",
		".golangci.json",
		"go.mod",
		"go.work",
		".git",
	},
}

---| Nix Ecosystem ----------------------------------

-- Nix (nixd)
local function get_home_dir()
	return os.getenv("HOME") or "~"
end

local function get_hostname()
	return os.getenv("HOSTNAME") or vim.loop.os_gethostname() or ""
end

vim.lsp.config.nixd = {
	cmd = { "nixd" },
	capabilities = capabilities,
	filetypes = { "nix" },
	settings = {
		nixd = {
			nixpkgs = { expr = "import <nixpkgs> {}" },
			formatting = { command = { "alejandra" } },
			options = {
				nixos = {
					expr = '(builtins.getFlake "'
						.. get_home_dir()
						.. '/.dotfiles/.config/nix").nixosConfigurations.'
						.. get_hostname()
						.. ".options",
				},
				nix_darwin = {
					expr = '(builtins.getFlake "'
						.. get_home_dir()
						.. '/.dotfiles/.config/nix").darwinConfigurations.'
						.. get_hostname()
						.. ".options",
				},
				home_manager = {
					expr = '(builtins.getFlake "'
						.. get_home_dir()
						.. '/.dotfiles/.config/nix").homeConfigurations.'
						.. get_hostname()
						.. ".options",
				},
			},
		},
	},
}

---| Lua Development ----------------------------------

-- Lua (lua-language-server)
vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		".git",
	},
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim", "require", "Snacks" },
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

---| Python Development ----------------------------------

-- Python (pyright)
vim.lsp.config.pyright = {
	capabilities = capabilities,
	filetypes = { "python" },
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic",
				diagnosticMode = "workspace",
				autoImportCompletions = true,
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" })
		if not root then
			local name = vim.api.nvim_buf_get_name(bufnr)
			root = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
		end
		on_dir(root)
	end,
}

---| R & Data Science ----------------------------------

-- R Language Server
vim.lsp.config.r_language_server = {
	on_attach = function(client, _)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	cmd = { "R", "--slave", "-e", "languageserver::run()" },
	filetypes = { "r", "rmd", "quarto" },
	capabilities = capabilities,
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, { "DESCRIPTION", ".git" })
		if not root then
			local name = vim.api.nvim_buf_get_name(bufnr)
			root = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
		end
		on_dir(root)
	end,
	settings = {
		r = {
			lsp = {
				diagnostics = true,
				rich_documentation = true,
			},
		},
	},
}

-- YAML (yaml-language-server) - for Quarto configuration
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
	vim.lsp.config.yamlls = {
		capabilities = capabilities,
		filetypes = { "yaml", "yml" },
		settings = {
			yaml = {
				schemas = {
					[quarto_schema_path] = { "*.qmd", ".quarto.yaml", "quarto.yml", "*.quarto.yml" },
				},
				completion = true,
				validate = true,
			},
		},
	}
else
	vim.lsp.config.yamlls = {
		capabilities = capabilities,
		filetypes = { "yaml", "yml" },
	}
end

---| Typesetting & Markup Languages --------------------------

-- Markdown (marksman)
vim.lsp.config.marksman = {
	capabilities = capabilities,
	filetypes = { "markdown" },
}

-- Typst (tinymist)
vim.lsp.config.tinymist = {
	capabilities = capabilities,
	cmd = { "tinymist" },
	filetypes = { "typst" },
	settings = {},
}

-- JSON (vscode-json-language-server)
vim.lsp.config.jsonls = {
	cmd = { "vscode-json-language-server", "--stdio" },
	capabilities = capabilities,
	filetypes = { "json", "jsonc" },
	settings = {
		json = {
			validate = { enable = true },
			format = { enable = false }, -- Formatting handled by jq via Conform
		},
	},
}

---| LSP Auto-Enable by FileType ----------------------------------
-- Enable LSP servers based on filetype (Neovim 0.12+ pattern)
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"bash",
		"go",
		"json",
		"jsonc",
		"lua",
		"markdown",
		"nix",
		"python",
		"quarto",
		"r",
		"rmd",
		"sh",
		"typst",
		"yaml",
		"yml",
	},
	callback = function(args)
		local server_map = {
			bash = "bashls",
			go = { "gopls", "golangci_lint_ls" },
			json = "jsonls",
			jsonc = "jsonls",
			lua = "lua_ls",
			markdown = "marksman",
			nix = "nixd",
			python = "pyright",
			quarto = "r_language_server",
			r = "r_language_server",
			rmd = "r_language_server",
			sh = "bashls",
			typst = "tinymist",
			yaml = "yamlls",
			yml = "yamlls",
		}
		local server = server_map[vim.bo[args.buf].filetype]
		if server then
			vim.lsp.enable(server)
		end
	end,
})

---==========================================================
---| EDITOR ENHANCEMENTS
---==========================================================

---| Gitsigns ----------------------------------
require("gitsigns").setup({
	word_diff = false,
})

---| Mini Modules ----------------------------------
require("mini.icons").setup({})
require("mini.surround").setup({
	custom_surroundings = {
		h = {
			-- Add:       sa h  (then motion)
			-- Replace:   sr h
			-- Delete:    sd h
			output = function()
				return { left = "==", right = "==" }
			end,
		},
	},
})

---| Lualine ----------------------------------
require("lualine").setup({
	options = {
		theme = "auto",
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		globalstatus = false,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { { "filename", path = 1 } }, -- relative path
		lualine_x = {
			{
				function()
					return vim.g.llama_status or ""
				end,
				color = { fg = "#918374" },
			},
			"filetype",
		},
		lualine_y = { "searchcount", "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "location" },
	},
})

---| Snacks ----------------------------------
require("snacks").setup({
	bigfile = { enabled = false },
	dashboard = {
		enabled = true,
		sections = {
			{ section = "header" },
			-- { section = "keys", gap = 1, padding = 1 },
		},
	},
	explorer = { enabled = false }, -- Using yazi
	git = { enabled = false },
	gitbrowse = { enabled = false },
	image = { enabled = false }, -- Using image.nvim
	input = { enabled = false },
	notifier = { enabled = false }, -- Using standard vim.notify
	picker = {
		enabled = true,
		formatters = {
			file = {
				filename_first = true,
			},
		},
		layout = {},
	},
	quickfile = { enabled = false },
	scope = { enabled = false },
	scroll = { enabled = false },
	gh = {
		enabled = true,
		win = {
			zindex = 50,
			style = "minimal",
		},
	},
	statuscolumn = { enabled = false },
	terminal = { enabled = false },
	toggle = { enabled = true }, -- Complements toggle functions
	words = { enabled = false },
})

-- Register Snacks picker as the vim.ui.select backend
vim.ui.select = Snacks.picker.ui_select

---| WhichKey ----------------------------------
require("which-key").setup({
	preset = "helix",
	delay = 2000,
	icons = {
		group = "",
	},
	plugins = {
		marks = true,
		registers = true,
	},
})

-- Add keymap groups
local wk = require("which-key")
wk.add({
	{ "<leader>b", group = "Buffer", icon = "󰓩 " },
	{ "<leader>c", group = "Code", icon = "󰌗" },
	{ "<leader>d", group = "Diagnostics/Debug", icon = "󰒡" },
	{ "<leader>e", group = "Explore", icon = "󰥩" },
	{ "<leader>f", group = "Files", icon = "󰈔" },
	{ "<leader>g", group = "Git", icon = "󰊢" },
	{ "<leader>gi", group = "GitHub issues", icon = "󰌚" },
	{ "<leader>h", group = "Help", icon = "󰋗" },
	{ "<leader>l", group = "LSP", icon = "󰅩" },
	{ "<leader>lc", group = "Call Hierarchy", icon = "󰘦" },
	{ "<leader>m", group = "Markdown", icon = "󰉫" },
	{ "<leader>o", group = "Obsidian", icon = "󱞁" },
	{ "<leader>q", group = "Quarto", icon = "󰠮" },
	{ "<leader>r", group = "References", icon = "󰒋" },
	{ "<leader>rb", desc = "BibTeX citations" },
	{ "<leader>s", group = "Search", icon = "󰢶" },
	{ "<leader>t", group = "Toggle", icon = "󰔡" },
	{ "<leader>u", group = "Update/Plugins", icon = "󰚰 " },
	{ "<leader>w", proxy = "<C-w>", group = "Windows", icon = "󰪷" },
	{ "<leader>x", desc = "Quit", icon = "󰗼" },
})

---| Treesitter ----------------------------------
require("nvim-treesitter").setup()

vim.api.nvim_create_autocmd("FileType", {
	group = "personal",
	callback = function()
		local ok = pcall(vim.treesitter.start)
		if not ok then
			vim.bo.syntax = "on" -- fallback to regex syntax
		end
	end,
})

---| Highlight Colors ----------------------------------
require("nvim-highlight-colors").setup({})

---| Yazi ----------------------------------
vim.g.loaded_netrwPlugin = 1
require("yazi").setup({
	open_for_directories = true,
	floating_window_scaling_factor = 0.95,
	yazi_floating_window_border = "single",
})

---==========================================================
---==== LAZY PLUGINS ====
---==========================================================
-- General data-driven loaders. Each table entry = { plugin_name, setup_fn }.
-- Config runs at load time via :packadd. Two autocommands cover all cases.
-- packadd on an already-loaded plugin is a no-op, so shared plugins
-- (e.g. render-markdown used by both markdown and quarto) are safe to list twice.

local function load(name, fn)
	vim.cmd("packadd " .. name)
	if fn then
		fn()
	end
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
						sign = false,
						language_border = " ",
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
		{
			"obsidian.nvim",
			function()
				require("obsidian").setup({
					legacy_commands = false,
					ui = { enable = false },
					checkbox = {
						order = { " ", "x", "/", "-", ">", "~", "!", "?" },
					},
					note_id_func = function(id, dir)
						return id
					end,
					workspaces = {
						{ name = "Notes", path = "~/Obsidian/Notes/" },
						{ name = "Personal", path = "~/Obsidian/Personal/" },
					},
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
					completion = { nvim_cmp = false, blink = true },
				})
			end,
		},
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

---| Command-triggered plugins ----------------------------------

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

---==========================================================
---| KEYMAPS FOR LAZY PLUGINS
---==========================================================

-- BibTeX keymap (snacks-bibtex loads lazily via FileType; keymap registered eagerly)
vim.keymap.set("n", "<leader>rb", function()
	require("snacks-bibtex").bibtex()
end, { desc = "BibTeX citations" })

-- Toggle between Pandoc and LaTeX citation formats
_G.Toggle_citation_format = function()
	local config = require("snacks-bibtex.config").get()
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
