{ pkgs, ... }: {
  extraPlugins = with pkgs.vimUtils; [
    (buildVimPlugin {
      pname = "copilot.lua";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "zbirenbaum";
        repo = "copilot.lua";
        rev = "86537b286f18783f8b67bccd78a4ef4345679625";
        hash = "sha256-HC1QZlqEg+RBz/8kjLadafc06UoMAjhh0UO/BWQGMY8=";
      };
    })
  ];

  extraConfigLua = ''
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<C-g>",
          accept_word = "<C-d>",
          accept_line = "<C-f>",
            },
          },
          panel = { enabled = false },
          filetypes = {
        [" * "] = true,
      },
    })
  '';
}
