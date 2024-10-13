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

      cmp-nvim-lsp.enable = true;
      cmp-path.enable = true;
      cmp_luasnip.enable = true;
      cmp-nvim-lsp-document-symbol.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;

      cmp = {
        enable = true;
        settings = {
          completion.autocomplete = false;
          autoEnableSources = true;
          formatting = { };
          sources = [
            { name = "luasnip"; }
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

      # cmp = {
      #   enable = true;
      #   settings = {
      #     autoEnableSources = true;
      #     experimental = { ghost_text = true; };
      #     formatting = {
      #       fields = [ "kind" "abbr" "menu" ];
      #     };
      #     sources = [
      #       {
      #         name = "luasnip";
      #         keywordLength = 3;
      #       }
      #       { name = "cmp_nvim_r"; }
      #       { name = "cmp-nvim-lsp"; }
      #       { name = "nvim_lsp"; }
      #       { name = "nvim_lsp_document_symbol"; }
      #       { name = "nvim_lsp_signature_help"; }
      #       { name = "path"; }
      #       { name = "treesitter"; }
      #     ];
      #     preselect = "None";
      #     snippet = {
      #       expand = "luasnip";
      #     };
      #     window = {
      #       completion = {
      #         border = "solid";
      #       };
      #       documentation = {
      #         border = "solid";
      #       };
      #     };
      #     mapping = {
      #       "<CR>" = "cmp.mapping.confirm({select = true })";
      #       "<C-d>" = "cmp.mapping.scroll_docs(-4)";
      #       "<C-f>" = "cmp.mapping.scroll_docs(4)";
      #       "<C-Space>" = "cmp.mapping.complete()";
      #       "<Tab>" =
      #         # lua
      #         ''
      #           cmp.mapping(function(fallback)
      #             if cmp.visible() then
      #               cmp.select_next_item()
      #             elseif luasnip.expand_or_locally_jumpable() then
      #               luasnip.expand_or_jump()
      #             else
      #               fallback()
      #             end
      #           end, { "i", "s" })
      #         '';
      #       "<S-Tab>" =
      #         # lua
      #         ''
      #           cmp.mapping(function(fallback)
      #             if cmp.visible() then
      #               cmp.select_prev_item()
      #            elseif luasnip.jumpable(-1) then
      #               luasnip.jump(-1)
      #             else
      #               fallback()
      #             end
      #           end, { "i", "s" })
      #         '';
      #       "<Down>" =
      #         # lua
      #         ''
      #           cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'})
      #         '';
      #       "<Up>" =
      #         # lua
      #         ''
      #           cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'})
      #         '';
      #     };
      #   };
      # };
    };
  };
}
