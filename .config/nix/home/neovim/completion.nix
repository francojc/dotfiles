{ pkgs, ... }:

{
  programs.nixvim = {
    plugins = {

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

      blink-cmp = {
        enable = true;
        settings = {
          accept = {
            auto_brackets = {
              enabled = true;
              semantic_token_resolution.enabled = true;
            };
          };
          trigger = {
            signature_help.enabled = true;
          };
          keymap = {
            "<C-b>" = [
              "scroll_documentation_up"
              "fallback"
            ];
            "<C-e>" = [
              "hide"
            ];
            "<C-f>" = [
              "scroll_documentation_down"
              "fallback"
            ];
            "<C-n>" = [
              "select_next"
              "fallback"
            ];
            "<C-p>" = [
              "select_prev"
              "fallback"
            ];
            "<C-space>" = [
              "show"
              "show_documentation"
              "hide_documentation"
            ];
            "<C-y>" = [
              "select_and_accept"
            ];
            "<Down>" = [
              "select_next"
              "fallback"
            ];
            "<S-Tab>" = [
              "snippet_backward"
              "fallback"
            ];
            "<Tab>" = [
              "snippet_forward"
              "fallback"
            ];
            "<Up>" = [
              "select_prev"
              "fallback"
            ];

          };
          completion = {
            documentation = {
              auto_show = true;
              auto_show_delay_ms = 500;
            };
            list = {
              selection = "manual";
            };
            menu = {
              draw = {
                gap = 2;
                treesitter = true;
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
                components = {
                  label = {
                    width.fill = true;
                  };
                  "kind_icon" = {
                    width.fill = true;
                  };
                };
              };
            };
          };
          sources = {
            completion.enabled_providers = [
              "lsp"
              "path"
              "luasnip"
              "snippets"
              "buffer"
            ];
            providers = {
              snippets = {
                opts = {
                  extended_filetypes = {
                    quarto = [ "markdown" ];
                  };
                };
              };
            };
          };
          signature = {
            enabled = true;
          };
        };
      };
    };
  };
}
