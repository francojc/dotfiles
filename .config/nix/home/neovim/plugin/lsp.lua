-- LSP config

local lspconfig = require("lspconfig")

-- Bash
lspconfig.bashls.setup {}

-- Lua 
lspconfig.lua_ls.setup {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc')) then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        }
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
  settings = {
    Lua = {}
  }
}

-- Nix
-- Get username and hostname from the system
local function get_username()
  local handle = io.popen("whoami")
  if not handle then return "" end
  local username = handle:read("*a")
  handle:close()
  return username:gsub("\n$", "") 
end

local function get_hostname()
  local handle = io.popen("hostname")
  if not handle then return "" end
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
          expr = '(builtins.getFlake \"/Users/' .. get_username() .. '/.dotfiles/.config/nix\").nixosConfigurations.' .. get_hostname() .. '.options',
        },
        nix_darwin = {
          expr = '(builtins.getFlake \"/Users/' .. get_username() .. '/.dotfiles/.config/nix\").darwinConfigurations.' .. get_hostname() .. '.options',
        },
        home_manager = {
          expr = '(builtins.getFlake \"/Users/' .. get_username() .. '/.dotfiles/.config/nix\").homeConfigurations.' .. get_hostname() .. '.options',
        },
      },
    },
  },
})

-- R
-- lspconfig.air.setup ({ })
lspconfig.r_language_server.setup({
  cmd = { "R", "--slave", "-e", "languageserver::run()" },
  filetypes = { "r" },
  root_dir = function(fname)
    return lspconfig.util.root_pattern("DESCRIPTION")(fname) or
           lspconfig.util.find_git_ancestor(fname) or
           lspconfig.util.path.dirname(fname)
  end,
  settings = {
    r = {
      diagnostics = {
        enable = true,
        globals = { "vim" }
      }
    }
  }
})
