-- UI config

-- Aerial ----------------------------------------------------------------
require("aerial").setup({
	on_attach = function(bufnr)
		-- Jump forwards/backwards with '{' and '}'
		vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
		vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
	end,
})

-- Alpha -------------------------------------------------------------------

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
	dashboard.button("s", "  Restore last session", ":SessionRestore<CR>"),
	dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("f", "  Find file", ":FzfLua files<CR>"),
	dashboard.button("r", "  Recent files", ":FzfLua oldfiles<CR>"),
	dashboard.button("g", "  Find text", ":FzfLua live_grep <CR>"),

	dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
}

-- Set footer
dashboard.section.footer.val = function()
	local end_time = vim.loop.hrtime()
	local start_time = _G.nvim_config_start_time or end_time -- Fallback if start time wasn't set
	local duration_ns = end_time - start_time
	local ms = math.floor(duration_ns / 1000000 + 0.5) -- Convert ns to ms and round
	return " Welcome back, " .. os.getenv("USER") .. "! Loaded in " .. ms .. "ms"
end

-- Send config to alpha
alpha.setup(dashboard.opts)

-- Disable folding on alpha
vim.cmd([[ autocmd FileType alpha setlocal nofoldenable ]])

-- Bufferline --------------------------------------------------------------
require("bufferline").setup({})

-- Colorizer ---------------------------------------------------------------
require("colorizer").setup({
	user_default_options = {
		mode = "virtualtext",
		names = false,
		virtualtext_inline = true,
	},
})

-- Fidget ----------------------------------------------------------------
require("fidget").setup({})

-- Image -------------------------------------------------------------------
require("image").setup({
	processor = "magick_cli",
	integrations = {
		markdown = {
			clear_in_insert_mode = true,
			filetypes = { "markdown", "quarto" },
			only_render_image_at_cursor = true,
		},
	},
})

-- Img-clip ----------------------------------------------------------------
require("img-clip").setup({
	default = {
		dir_path = "./images",
		relative_to_current_file = true,
		show_dir_path_in_prompt = true,
	},
})

-- Lualine ----------------------------------------------------------------
-- Lualine helper function to get attached LSP servers
local function get_lsp_servers()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return ""
	end

	local server_icons = {
		["GitHub Copilot"] = "",
		["lua_ls"] = "",
		["nixd"] = "",
		["otter-ls"] = "",
		["pyright"] = "",
		["r_language_server"] = "",
		["render-markdown"] = "",
		["bashls"] = "",
		["yamlls"] = "",
	}

	local client_names = {}
	for _, client in ipairs(clients) do
		local name = client.name
		-- Remove buffer numbers, e.g. `[3]` from `name`
		name = name:gsub("%[.*%]", "")
		if server_icons[name] then
			table.insert(client_names, server_icons[name])
		else
			table.insert(client_names, name)
		end
	end
	return table.concat(client_names, " | ")
end

-- Lualine setup
require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = " ", right = " " },
		section_separators = { left = " ", right = " " },
		disabled_filetypes = {
			statusline = { "neo-tree", "toggleterm", "alpha", "codecompanion", "aerial" },
			winbar = { "alpha" },
		},
		always_divide_middle = true,
		globalstatus = true,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "lsp_progress", get_lsp_servers },
		lualine_y = { " filetype" },
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

-- Render-Markdown ------------------------------------------------------
require("render-markdown").setup({
	anti_conceal = { enabled = true },
	bullet = {
		icons = { "■ ", "□ ", "▪ ", "▫ " },
		left_pad = 0,
		right_pad = 1,
	},
	code = {
		style = "normal",
		language_name = false,
	},
	completions = { lsp = { enabled = true } },
	conceal = { level = 2 },
	dash = { enabled = false },
	file_types = { "markdown", "quarto", "codecompanion" },
	heading = {
		backgrounds = {},
		icons = {
			"# ",
			"## ",
			"### ",
			"#### ",
			"##### ",
		},
		left_pad = 0,
		position = "inline",
		right_pad = 3,
		width = "full",
	},
	html = {
		enabled = true,
		comment = { conceal = false },
	},
	pipe_table = {
		preset = "round",
	},
	-- win_options = { conceallevel = { rendered = 1 } },
})
