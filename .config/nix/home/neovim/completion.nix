{ pkgs, ... }:

{
  programs.nixvim = {
    plugins = {

      friendly-snippets.enable = true;

      luasnip = {
        enable = true;
        filetypeExtend = {
          quarto = [ "markdown" ];
          rmarkdown = [ "markdown" ];
        };
        settings = {
          enable_autosnippets = true;
        };
        fromVscode = [
          { }
          { paths = [ (builtins.path { path = ./snippets; }) ]; }
        ];
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        filetype = {
          markdown = {
            sources = [
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "path"; }
            ];
          };
        };
        settings = {
          completion = {
            completeopt = "menu,menuone,noselect";
          };
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
          snippet = {
            expand =
              ''
                function(args)
                  require('luasnip').expand(args.body)
                end
              '';
          };
          sources =
            [
              { name = "nvim_lsp_signature_help"; }
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "pandoc_references"; }
              { name = "path"; }
              { name = "buffer"; keyword_length = 5; }
            ];
        };
      };
    };
  };
}
