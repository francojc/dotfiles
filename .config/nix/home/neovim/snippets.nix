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
          {paths = ./snippets;}
        ];
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
}
