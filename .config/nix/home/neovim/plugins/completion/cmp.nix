{
  plugins = {
    cmp = {
      enable = true;
      settings = {
        autoEnableSources = true;
        preselect = "None";
        experimental = { ghost_text = false; };
        performance = {
          debounce = 60;
          fetchingTimeout = 200;
          maxViewEntries = 30;
        };
        snippet = {
          expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
          completion = {
            keyword_length = 3;
            autocomplete = false;
          };
        };
        formatting = { fields = [ "kind" "abbr" "menu" ]; };
        sources = [
          { name = "otter"; }
          { name = "nvim_lsp"; }
          # { name = "emoji"; }
          # { name = "buffer"; } # text within current buffer }
          # { name = "copilot"; }
          { name = "path"; } # file system paths
          { name = "luasnip"; } # snippets
          { name = "nvim_lsp_signature_help"; }
          { name = "treesitter"; }
        ];

        window = {
          completion = {
            border = "solid";
            side_padding = 0;
          };
          documentation = {
            border = "solid";
            side_padding = 0;
          };
        };
        mapping = {
          "<CR>" = "cmp.mapping.confirm({select = true })";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<Tab>" = # lua
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
          "<S-Tab>" = # lua
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
          "<Down>" = "cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'})";
          "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'})";
        };
      };
    };
    cmp-buffer = { enable = false; }; # text within current buffer
    cmp-cmdline = { enable = true; }; # autocomplete for cmdline
    cmp-emoji = { enable = false; }; # emoji
    cmp_luasnip = { enable = true; }; # snippets
    cmp-nvim-lsp = { enable = true; }; # lsp
    cmp-nvim-lsp-signature-help = { enable = true; }; # signature help
    cmp-path = { enable = true; }; # file system paths
    cmp-treesitter = { enable = true; }; # treesitter
    otter = { enable = true; }; # quarto completion
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
}
