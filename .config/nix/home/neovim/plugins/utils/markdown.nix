{ pkgs, ... }: {
  extraPlugins = with pkgs.vimUtils; [
    (buildVimPlugin {
      pname = "markdown.nvim";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "MeanderingProgrammer";
        repo = "markdown.nvim";
        rev = "a1bcbf4858d1834f922029b5fc6ae55a7417bd51";
        hash = "sha256-LJLgozxPLzR/qCLv9pUP/qUgnXfhlWZC7zQG9ZlDwqI=";
      };
    })
  ];

  extraConfigLua = '' 
  require("render-markdown").setup({
      code = {
        style = "language",
        position = "right",
      },
      bullet = {
        icons = { "▪", "▫", "◦", "◦", "◦", "◦" },
      },
      file_types = { "markdown", "quarto", "vimwiki" },
    })
  '';
}
