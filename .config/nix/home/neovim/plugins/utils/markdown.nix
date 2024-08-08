{ pkgs, ... }: {
  extraPlugins = with pkgs.vimUtils; [
    (buildVimPlugin {
      pname = "render-markdown.nvim";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "MeanderingProgrammer";
        repo = "render-markdown.nvim";
        rev = "a1bcbf4858d1834f922029b5fc6ae55a7417bd51";
        hash = "sha256-LJLgozxPLzR/qCLv9pUP/qUgnXfhlWZC7zQG9ZlDwqI=";
      };
    })
  ];

  extraConfigLua = ''
    require("render-markdown").setup({
        heading = {
          position = "inline",
        },
        code = {
          width = "block",
        },
        bullet = {
          icons = { "▪", "▫", "◦", "◦", "◦", "◦" },
        },
        quote = {
          icon = "❝",
        },
        file_types = { "markdown", "quarto", "qmd", "vimwiki" },
      })
  '';
}
