{
  programs.nixvim = {
    plugins = {
      friendly-snippets.enable = true;

      luasnip = {
        enable = true;
        filetypeExtend = {
          quarto = ["markdown"];
          rmarkdown = ["markdown"];
        };
        settings = {
          enable_autosnippets = true;
        };
        fromVscode = [
          {}
          {paths = [(builtins.path {path = ./snippets;})];}
        ];
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        filetype = {
          markdown = {
            sources = [
              {name = "nvim_lsp";}
              {name = "luasnip";}
              {name = "path";}
            ];
          };
        };
        settings = {
          completion = {
            completeopt = "menu,menuone,noselect";
          };
          formatting = {
            fields = [
              "abbr"
              "kind"
              "menu"
            ];
            expandable_indicator = true;
          };
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = ''
              cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif require('luasnip').locally_jumpable(1) then
                    require('luasnip').jump(1)
                  else
                    fallback()
                  end
              end, {'i', 's'})'';

            "<S-Tab>" = ''
              cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif require('luasnip').locally_jumpable(-1) then
                    require('luasnip').jump(-1)
                  else
                    fallback()
                  end
              end, {'i', 's'})'';
          };
          snippet = {
            expand = ''
              function(args)
                require('luasnip').expand(args.body)
              end
            '';
          };
          sources = [
            {
              name = "luasnip";
              keyword_length = 3;
            }
            {name = "nvim_lsp";}
            {name = "nvim_lsp_document_symbol";}
            {name = "nvim_lsp_signature_help";}
            {name = "treesitter";}
            {name = "path";}
            {
              name = "buffer";
              keyword_length = 5;
            }
          ];
          performance = {
            debounce = 60;
            fetching_timeout = 200;
            max_view_entries = 30;
          };
          window = {
            completion = {
              border = "rounded";
              winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None";
            };
            documentation = {
              border = "rounded";
            };
          };
        };
      };
    };
    extraConfigLua = ''
      luasnip = require("luasnip")
      kind_icons = {
        Text = "󰊄",
        Method = "",
        Function = "󰡱",
        Constructor = "",
        Field = "",
        Variable = "󱀍",
        Class = "",
        Interface = "",
        Module = "󰕳",
        Property = "",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = "",
      }

    '';
  };
}
