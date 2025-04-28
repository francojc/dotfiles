-- LSP server/formatting config

-- Language servers -------------------------------------------------------

local lspconfig = require("lspconfig")

-- Bash
lspconfig.bashls.setup({}) -- Pass an empty table here

-- Lua
lspconfig.lua_ls.setup({}) -- Also good practice to add {} here

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

local configs = require("lspconfig.configs")

-- Check if the config is already defined (useful when reloading this file)
if not configs.air then
	configs.air = {
		default_config = {
			cmd = { vim.fn.expand("$HOME/.local/bin/air"), "language-server" },
			filetypes = { "r", "quarto" },
			root_dir = function(fname)
				return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1]) or vim.loop.os_homedir()
			end,
			settings = {},
		},
	}
end

-- lspconfig.air.setup({})

lspconfig.r_language_server.setup({
	cmd = { "R", "--slave", "-e", "languageserver::run()" },
	filetypes = { "r", "quarto" },
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

-- YAML
lspconfig.yamlls.setup({})

-- Formatting ------------------------------------------------------

require("conform").setup({
	formatters_by_ft = {
		bash = { "shfmt" },
		lua = { "stylua" },
		nix = { "alejandra" },
		r = { "air" },
		markdown = { "mdformat" },
		quarto = { "air", "prettier" },
		["_"] = { "trim_whitespace" },
	},
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 500,
	},
})

require("conform").formatters.mdformat = {
	options = {
		ft_parsers = { markdown = "markdown" },
		ext_parsers = { qmd = "markdown" },
	},
}
