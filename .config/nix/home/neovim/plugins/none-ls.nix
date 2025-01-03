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
            checkstyle.enable = true; # xml linter
            statix.enable = true; # nix linter
            yamllint.enable = true; # yaml linter
          };
          formatting = {
            alejandra.enable = true;
            markdownlint.enable = true; # markdown linter
            prettier = {
              enable = true;
              disableTsServerFormatter = true;
              settings = {
                extra_args = ["--no-semi" "--single-quote"];
              };
            };
            tidy.enable = true; # html linter
            stylua.enable = true; # lua linter
            yamlfmt.enable = true; # yaml linter
          };
        };
      };
    };
  };
}
