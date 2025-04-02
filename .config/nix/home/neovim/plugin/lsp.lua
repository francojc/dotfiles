-- LSP server/formatting config

-- Language servers -------------------------------------------------------

local lspconfig = require("lspconfig")

-- Bash
lspconfig.bashls.setup()

-- Lua
lspconfig.lua_ls.setup()

-- Markdown
lspconfig.marksman.setup({
	cmd = { "marksman", "server" },
	filetypes = { "markdown", "quarto" },
})

-- Nix
-- Get username and hostname from the system
local function get_username()
	local handle = io.popen("whoami")
	if not handle then
		return ""
	end
	local username = handle:read("*a")
	handle:close()
	return username:gsub("\n$", "")
end

local function get_hostname()
	local handle = io.popen("hostname")
	if not handle then
		return ""
	end
	local hostname = handle:read("*a")
	handle:close()
	return hostname:gsub("\n$", "")
end

lspconfig.nixd.setup({
	cmd = { "nixd" },
	settings = {
		nixd = {
			nixpkgs = { expr = "import <nixpkgs> {}" },
			formatting = { command = { "alejandra" } },
			options = {
				nixos = {
					expr = '(builtins.getFlake "/Users/'
						.. get_username()
						.. '/.dotfiles/.config/nix").nixosConfigurations.'
						.. get_hostname()
						.. ".options",
				},
				nix_darwin = {
					expr = '(builtins.getFlake "/Users/'
						.. get_username()
						.. '/.dotfiles/.config/nix").darwinConfigurations.'
						.. get_hostname()
						.. ".options",
				},
				home_manager = {
					expr = '(builtins.getFlake "/Users/'
						.. get_username()
						.. '/.dotfiles/.config/nix").homeConfigurations.'
						.. get_hostname()
						.. ".options",
				},
			},
		},
	},
})

-- R
-- lspconfig.air.setup ()
lspconfig.r_language_server.setup({
	cmd = { "R", "--slave", "-e", "languageserver::run()" },
	filetypes = { "r" },
	root_dir = function(fname)
		return lspconfig.util.root_pattern("DESCRIPTION")(fname)
			or lspconfig.util.find_git_ancestor(fname)
			or lspconfig.util.path.dirname(fname)
	end,
	settings = {
		r = {
			diagnostics = {
				enable = true,
				globals = { "vim" },
			},
		},
	},
})

-- Formatting ------------------------------------------------------

require("conform").setup({
	formatters_by_ft = {
		bash = { "shfmt" },
		lua = { "stylua" },
		nix = { "alejandra" },
		r = { "styler" },
		markdown = { "prettier" },
	},
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 500,
	},
})
