{ pkgs, ... }: {
  programs.nixvim = {
    extraPlugins = with pkgs.vimUtils; [
      (buildVimPlugin {
        pname = "codecompanion.nvim";
        version = "unstable";
        src = pkgs.fetchFromGitHub {
          owner = "olimorris";
          repo = "codecompanion.nvim";
          rev = "fc146070cc341b1503d61daf6746edb4d0d7e6aa";
          hash = "sha256-UiB05lSjiKWq3eGQln9zMkNVzf3n1r7U3H1sVlrcz7k=";
        };
      })
    ];

    extraConfigLua = ''
      require("codecompanion").setup({ })
    '';
  };
}
