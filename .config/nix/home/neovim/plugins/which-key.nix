{
  programs.nixvim = {
    plugins.which-key = {
      enable = true;
      settings = {
        spec = [
          {
            __unkeyed-1 = "<leader>a";
            mode = "n";
            group = "Assistants";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>a";
            mode = "v";
            group = "Copilot";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>c";
            mode = "v";
            group = "CodeCompanion";
            icon = " ";
          }
          {
            __unkeyed-1 = "<leader>b";
            group = "Buffers";
            icon = " ";
          }
          {
            __unkeyed-1 = "<leader>c";
            group = "Code";
            icon = " ";
          }
          {
            __unkeyed-1 = "<leader>d";
            group = "Debug";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>f";
            group = "Files";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>h";
            group = "Help";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>m";
            mode = [ "n" "v" ];
            group = "Markdown";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>o";
            group = "Obsidian";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>p";
            group = "Copy/Paste";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>q";
            group = "Quarto";
            icon = "⨁";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "Search";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "Terminal";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>w";
            group = "Windows";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>\\";
            group = "Toggle";
          }
        ];
      };
    };
  };
}
