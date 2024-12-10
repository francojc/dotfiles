{ pkgs, ... }:

{
  programs.nixvim = {
    plugins = {
      cmp-nvim-lsp = { enable = true; };
      cmp-nvim-lsp-document-symbol = { enable = true; };
      cmp-nvim-lsp-signature-help = { enable = true; };
      cmp-pandoc-nvim = { enable = true; };
      friendly-snippets.enable = true;

      luasnip = {
        enable = true;
        filetypeExtend = {
          quarto = [ "markdown" ];
        };
        settings = {
          enable_autosnippets = true;
        };
        fromVscode = [
          { paths = "${pkgs.vimPlugins.friendly-snippets}"; }
        ];
      };

      nvim-snippets = {
        enable = true;
        settings = {
          friendly_snippets = true;
          extended_filetypes = {
            quarto = [ "markdown" ];
          };
          global_snippets = [
            "all"
            "loremipsum"
            "html"
            "quarto"
          ];

          search_paths = [
            {
              __raw = "vim.fn.stdpath('config') .. '/home/neovim/snippets'";
            }
          ];
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = false;
        settings = {
          formatting = {
            fields = [ "abbr" "kind" "menu" ];
          };
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() elseif require('luasnip').expand_or_jumpable() then require('luasnip').expand_or_jump() else fallback() end end, { 'i', 's' })";
            "<S-Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() elseif require('luasnip').jumpable(-1) then require('luasnip').jump(-1) else fallback() end end, { 'i', 's' })";
            "<Down>" = "cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { 'i' })";
            "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { 'i' })";
          };
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          sources = [
            { name = "cmp_pandoc"; }
            { name = "luasnip"; }
            { name = "nvim_lsp"; }
            { name = "nvim_lsp_document_symbol"; }
            { name = "nvim_lsp_signature_help"; }
            { name = "path"; }
            { name = "snippets"; }
          ];
          window = {
            completion.border = "solid";
            documentation.border = "solid";
          };
        };
      };
    };
  };
}
