{ pkgs, ... }:
{
  plugins.treesitter = {
    enable = true;
    settings = {
      auto_install = true;
      ensure_installed = [
        "r"
        "python"
        "markdown"
        "markdown_inline"
        "bash"
        "vim"
        "vimwiki"
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

  extraFiles = { };
  extraConfigLua = '''';
}
