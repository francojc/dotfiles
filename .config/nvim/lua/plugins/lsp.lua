---| LANGUAGE SERVERS (LSP) -----------------------------
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
