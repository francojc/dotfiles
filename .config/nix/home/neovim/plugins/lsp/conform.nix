{
  plugins.conform-nvim = {
    enable = true;
    formatOnSave = {
      lspFallback = true;
      timeoutMs = 500;
    };
    notifyOnError = true;
    formattersByFt = {
      html = [ [ "prettierd" "prettier" ] ];
      css = [ [ "prettierd" "prettier" ] ];
      javascript = [ [ "prettierd" "prettier" ] ];
      javascriptreact = [ [ "prettierd" "prettier" ] ];
      typescriptreact = [ [ "prettierd" "prettier" ] ];
      python = [ "black" ];
      lua = [ "stylua" ];
      nix = [ "nixpkgs-fmt" ];
      markdown = [ [ "prettierd" "prettier" ] ];
      yaml = [ "yamllint" "yamlfmt" ];
    };
  };
}
