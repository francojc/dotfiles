{
  plugins = {
    cmp-emoji = { enable = true; };
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
            function()
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
          {
            name = "otter";
          }
          {
            name = "nvim_lsp";
            keyword_length = 3;
            group_index = 2;
          }
          {
            name = "emoji";
            trigger_characters = [ ":" ];
          }
          {
            name = "buffer"; # text within current buffer
            option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
            keyword_length = 3;
            group_index = 4;
          }
          # { name = "copilot"; }
          {
            name = "path"; # file system paths
          }
          {
            name = "luasnip"; # snippets
            keyword_length = 3;
            trigger_characters = [ "+" ];
            priority = 1;
            group_index = 1;
          }
          {
            name = "nvim_lsp_signature_help";
          }
          {
            name = "treesitter";
          }
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
                -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                -- they way you will only jump inside the snippet region
                elseif luasnip.expand_or_locally_jumpable() then
                  luasnip.expand_or_jump()
                -- -- seems to interfere with copilot buffer selection 
                -- elseif has_words_before() then
                --   cmp.complete()
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
    cmp-nvim-lsp = { enable = true; }; # lsp
    cmp-buffer = { enable = true; };
    cmp-path = { enable = true; }; # file system paths
    cmp_luasnip = { enable = true; }; # snippets
    cmp-cmdline = { enable = false; }; # autocomplete for cmdline
    cmp-nvim-lsp-signature-help = { enable = true; };
    cmp-treesitter = { enable = true; };
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
