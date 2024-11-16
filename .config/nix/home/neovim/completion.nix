{ pkgs, ... }:

{
  programs.nixvim = {
    plugins = {
      luasnip = {
        enable = true;
        settings = {
          enable_autosnippets = true;
          history = true;
          updateevents = "TextChanged,TextChangedI";
        };
        fromVscode = [
          {
            lazyLoad = true;
            paths = "${pkgs.vimPlugins.friendly-snippets}";
          }
        ];
      };

      nvim-snippets = {
        enable = true;
        settings = {
          friendly_snippets = true;
          extended_filetypes = {
            quarto = [
              "markdown"
            ];
          };
          global_snippets = [
            "all"
            "loremipsum"
            "html"
          ];
          search_paths = [
            {
              __raw = "vim.fn.stdpath('config') .. '/snippets'";
            }
          ];
        };
      };

      cmp-nvim-lsp.enable = true;
      cmp-path.enable = true;
      cmp_luasnip.enable = true;
      cmp-nvim-lsp-document-symbol.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;

      cmp = {
        enable = true;
        settings = {
          # completion.autocomplete = false;
          autoEnableSources = true;
          formatting = {
            fields = [ "kind" "abbr" "menu" ];
          };
          sources = [
            { name = "luasnip"; }
            { name = "nvim-snippets"; }
            { name = "cmp-nvim-lsp"; }
            { name = "nvim_lsp"; }
            { name = "nvim_lsp_document_symbol"; }
            { name = "nvim_lsp_signature_help"; }
            { name = "path"; }
            { name = "treesitter"; }
          ];
          snippet.expand.__raw = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
          window = {
            completion.border = "solid";
            documentation.border = "solid";
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
        };
      };
    };
  };
}
