-- LSP config
--

-- local capabilities = vim.lsp.protocol.make_client_capabilities()
--
-- capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
-- capabilities = vim.tbl_deep_extend("force", capabilities, {


local lspconfig = require("lspconfig") 

-- Bash 
lspconfig.bashls.setup {}

-- Nix
-- Get username and hostname from the system

local function get_username()
  local handle = io.popen("whoami")
  local username = handle:read("*a")
  handle:close()
  return username
end

local function get_hostname()
  local handle = io.popen("hostname")
  local hostname = handle:read("*a")
  handle:close()
  return hostname
end

lspconfig.nixd.setup({
  cmd = { "nixd" },
  settings = {
    nixd = {
      nixpkgs = { expr = "import <nixpkgs> {}" }, },
      formatting = { command = { "alejandra" } },
      options = {
        nixos = {
          expr = '(builtins.getFlake \"/Users/' .. get_username() .. '/.dotfiles/.config/nix\").nixosConfigurations.' .. get_hostname() .. '.options'),
        },
        nix_darwin = {
          expr = '(builtins.getFlake \"/Users/' .. get_username() .. '/.dotfiles/.config/nix\").darwinConfigurations.' .. get_hostname() .. '.options'),
        },
        home_manager = {
          expr = '(builtins.getFlake \"/Users/' .. get_username() .. '/.dotfiles/.config/nix\").homeConfigurations.' .. get_hostname() .. '.options'),
        },
      },
    },
  },
})

-- R 
lspconfig.air.setup {}
