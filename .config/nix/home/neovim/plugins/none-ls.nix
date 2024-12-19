{
  programs.nixvim = {
    plugins = {
      none-ls = {
      enable = true;
      enableLspFormat = true;
      settings = {
        update_in_insert = true;
      };
      sources = {
        code_actions = {
          gitsigns.enable = true;
          statix.enable = true;
        };
        diagnostics = {
          pylint.enable = true; # python linter
          mypy.enable = true; # python type checker
          statix.enable = true; # nix linter
          yamllint.enable = true; # yaml linter
        };
        formatting = {
          nixpkgs_fmt.enable = true;
          black = {
            enable = true;
            settings = {
              extra_args = [ "--fast" ];
            };
          };
          prettier = {
            enable = true;
            disableTsServerFormatter = true;
            settings = {
              extra_args = [ "--no-semi" "--single-quote" ];
            };
          };
          stylua.enable = true;
          yamlfmt.enable = true;
        };
      };
      };
      lsp-format.enable = true;
    };
  };
}
