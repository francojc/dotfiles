{
  imports = [
# ./autocommands.nix
# ./completion.nix
# ./keymaps.nix
# ./lsp.nix
# ./options.nix
# ./plugins/default.nix
# ./snippets.nix
  ];

# Hello 
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        enableLuaLoader = true;

        autocmds = [
          {
            enable = false;
            event = "TextYankPost";
            desc = "Highlight yanked text";
            group = "personal";
            callback = ":lua
              function()
                vim.highlight.on_yank()
              end
            ";
          }
        ];

        autopairs.nvim-autopairs.enable = true;

        assistant = {
          codecompanion-nvim = {
            enable = true;
            # setup codecompanion  
          };
          copilot = {
            enable = true;
            mappings = {
              suggestion = {
              # TODO: find out how to auto-enable suggestions (:Copilot suggestions)
                acceptLine = "<C-f>";
                acceptWord = "<C-d>";
                next = "<C-]";
                prev = "<C-[";
                dismiss = "<C-e>"; 
              };
            };
          };
        };
        diagnostics = {
          nvim-lint = {
            enable = true;
            lint_after_save = true;
          };
        };
        fzf-lua = {
          enable = true;
          profile = "fzf-native";
        };
        keymaps = [
          {
            mode = "i";
            key = "jj";
            action = "<Esc>";
            desc = "Use jj as <Esc>";
            silent = true;
          }
        ];
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          nix.enable = true;
          bash.enable = true;
        };
        options = {
          breakindent = true;
          linebreak = true;
          shiftwidth = 2;
          showbreak = "↳";
          showmode = false;
          tabstop = 2;
          winborder = "rounded";
        };
        statusline = {
          lualine.enable = true;
        };
      };
    };
  };
}
