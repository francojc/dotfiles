{
  programs.nixvim = {
    plugins = {
      blink-cmp = {
        enable = true;
        settings = {
          appearance = {
            use_nvim_cmp_as_default = true;
            kind_icons = {
              Text = "󰊄";
              Method = "";
              Function = "󰡱";
              Constructor = "";
              Field = "";
              Variable = "󱀍";
              Class = "";
              Interface = "";
              Module = "󰕳";
              Property = "";
              Unit = "";
              Value = "";
              Enum = "";
              Keyword = "";
              Snippet = "";
              Color = "";
              File = "";
              Reference = "";
              Folder = "";
              EnumMember = "";
              Constant = "";
              Struct = "";
              Event = "";
              Operator = "";
              TypeParameter = "";
            };
          };
          completion = {
            accept.auto_brackets.enabled = true;
            documentation = {
              auto_show = true;
              auto_show_delay_ms = 500;
              treesitter_highlighting = true;
            };
            list = {
              selection = {
                preselect = false;
                auto_insert = true;
              };
            };
            menu = {
              auto_show.__raw = ''
                function(ctx)
                  return ctx.mode ~= 'cmdline' or not vim.tbl_contains({'/', '?'}, vim.fn.getcmdtype())
                end
              '';
              draw = {
                gap = 2;
                treesitter = ["lsp"];
                columns = [
                  {
                    __unkeyed-1 = "label";
                    __unkeyed-2 = "label_description";
                    gap = 1;
                  }
                  {
                    __unkeyed-1 = "kind_icon";
                    __unkeyed-2 = "kind";
                    gap = 1;
                  }
                ];
              };
            };
          };
          keymap = {
            # preset = "enter";
            "<C-space>" = ["show" "show_signature" "hide_signature" "fallback"];
            "<C-e>" = ["hide"];
            "<CR>" = ["accept" "fallback"];
            "<Tab>" = ["snippet_forward" "fallback"];
            "<S-Tab>" = ["snippet_backward" "fallback"];
            "<C-j>" = ["select_next" "fallback"];
            "<C-k>" = ["select_prev" "fallback"];
          };
          signature.enabled = true;
          snippets = {
            preset = "luasnip";
            expand.__raw = ''
              function(snippet) require('luasnip').lsp_expand(snippet) end
            '';
            active.__raw = ''
              function(filter)
                if filter and filter.direction then
                  return require('luasnip').jumpable(filter.direction)
                end
                return require('luasnip').in_snippet()
              end
            '';
            jump.__raw = ''
              function(direction) require('luasnip').jump(direction) end
            '';
          };
          sources = {
            min_keyword_length.__raw = ''
              function(ctx)
                if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then return 3
                end
                return 0
              end
            '';
            # per_filetype = {
            #   "markdown" = ["lsp" "path" "snippets"];
            #   "quarto" = ["lsp" "path" "snippets"];
            # };
            default = ["lsp" "path" "snippets"];
          };
        };
      };

      blink-compat = {
        enable = true;
      };

      cmp = {
        enable = false;
        autoEnableSources = true;
        filetype = {
          markdown = {
            sources = [
              {name = "render-markdown";}
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
            {name = "nvim_lsp_document_symbol";}
            {name = "nvim_lsp_signature_help";}
            {name = "treesitter";}
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
  };
}
