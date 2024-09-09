{ pkgs, ... }: {
  programs.nixvim = {
    opts.completeopt = [ "menuone" "noselect" "noinsert" ];

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

      cmp = {
        enable = true;
        settings = {
          autoEnableSources = true;
          experimental = { ghost_text = false; };
          formatting = {
            fields = [ "kind" "abbr" "menu" ];
            format =
              # lua
              ''
                function(_, vim_item)
                  kind_icons = {
                    Text = "󰊄",
                    Spell = "󰊄",
                    String = "󰊄",
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
                    Reference = "󰈇",
                    Folder = "",
                    EnumMember = "",
                    Constant = "",
                    Struct = "",
                    Event = "",
                    Operator = "",
                    TypeParameter = "",
                    }
                  vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
                  return vim_item
                end
              '';
          };
          sources = [
            {
              name = "luasnip";
              keywordLength = 3;
            }
            { name = "nvim_lsp"; }
            { name = "nvim_lsp_document_symbol"; }
            { name = "nvim_lsp_signature_help"; }
            { name = "otter"; }
            { name = "path"; }
            { name = "treesitter"; }
          ];
          preselect = "None";
          snippet = {
            expand = "luasnip";
          };
          window = {
            completion = {
              border = "solid";
            };
            documentation = {
              border = "solid";
            };
          };
          mapping = {
            "<CR>" = "cmp.mapping.confirm({select = true })";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<Tab>" =
              # lua
              ''
                cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                  else
                    fallback()
                  end
                end, { "i", "s" })
              '';
            "<S-Tab>" =
              # lua
              ''
                cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                 elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                  else
                    fallback()
                  end
                end, { "i", "s" })
              '';
            "<Down>" =
              # lua
              ''
                cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'})
              '';
            "<Up>" =
              # lua
              ''
                cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'})
              '';
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
          Reference = "󰈇",
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
