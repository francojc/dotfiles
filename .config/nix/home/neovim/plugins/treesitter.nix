{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      languageRegister.markdown = "quarto";
      settings = {
        auto_install = true;
        ensure_installed = [
          "r"
          "python"
          "markdown"
          "markdown_inline"
          "bash"
          "vim"
          "latex"
          "regex"
          "html"
          "css"
          "dot"
          "javascript"
          "mermaid"
          "query"
        ];
        indent = { enable = true; };
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
      };
      folding = true;
    };

    plugins.treesitter-context.enable = true;
  };
}
