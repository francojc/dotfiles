{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      nixGrammars = true;
      languageRegister.markdown = ["quarto" "rmd"];
      settings = {
        auto_install = true;
        autopairs = true;
        ensure_installed = [
          "bash"
          "css"
          "csv"
          "dot"
          "html"
          "javascript"
          "latex"
          "lua"
          "markdown"
          "markdown_inline"
          "mermaid"
          "nix"
          "python"
          "r"
          "regex"
          "query"
          "toml"
          "vim"
          "yaml"
        ];
        folding = true;
        highlight = {
          enable = true;
          additional_vim_regex_highlighting = false;
        };
        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "<C-space>";
            node_incremental = "<C-space>";
            scope_incremental = false;
            node_decremental = "<bs>";
          };
        };
        indent = {enable = true;};
      };
      nixvimInjections = true;
    };

    plugins.treesitter-context.enable = true;
  };
}
