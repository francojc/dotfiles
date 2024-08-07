{ pkgs, ... }: {
  extraPlugins = with pkgs.vimUtils; [
    (buildVimPlugin {
      pname = "quarto-nvim";
      version = "1.0.1";
      src = pkgs.fetchFromGitHub {
        owner = "quarto-dev";
        repo = "quarto-nvim";
        rev = "eed598983fa4040eed77191f69462c1348770b8a";
        hash = "sha256-2XLuEAP2nrNDj+6qEgvoXn2Kj0UhH4QGYeuRD3UUR30=";
      };
    })
  ];

  extraConfigLua = ''
    require("quarto").setup({
      debug = false,
      closePreviewOnExit = true,
      lspFeatures = {
        enabled = true,
        chunks = "curly",
        languages = {
          "r", "python", "bash", "html"
        },
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
        codeRunner = { 
          enabled = false,
          default_method = "slime",
          never_run = { "yaml" },
        },
      },
    })
  '';
}
