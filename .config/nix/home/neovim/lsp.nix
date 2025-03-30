{
  config, # Added config to access homeDirectory
  username,
  hostname,
  ...
}: {
  programs.nixvim = {
    plugins = {
      lsp = { };
      lspkind = { };
    };
  };
}
