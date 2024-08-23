{
  programs.nixvim = {
    plugins.none-ls = {
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
          statix.enable = true;
          yamllint.enable = true;
        };
        formatting = {
          format_r.enable = true;
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
  };
}
