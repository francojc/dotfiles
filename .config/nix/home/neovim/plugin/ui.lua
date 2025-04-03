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
require("alpha").setup(require("alpha.themes.startify").config)

-- Bufferline --------------------------------------------------------------
require("bufferline").setup({})

-- Colorizer ---------------------------------------------------------------
require("colorizer").setup({
	user_default_options = {
		mode = "virtualtext",
		virtualtext_inline = true,
	},
})

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
		["marksman"] = "",
		["r_language_server"] = "",
		["lua_ls"] = "",
		["pyright"] = "",
		["nixd"] = "",
	}

	local client_names = {}
	for _, client in ipairs(clients) do
		local name = client.name
		if server_icons[name] then
			table.insert(client_names, server_icons[name])
		else
			table.insert(client_names, name)
		end
	end
	return table.concat(client_names, ", ")
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

-- Render Markdown
require("render-markdown").setup({
	file_types = { "markdown", "quarto" },
	heading = { enabled = true },
	bullet = {
		icons = { "■", "□", "▪", "▫" },
		right_pad = 1,
	},
	dash = { enabled = false },
	html = { enabled = false },
})
