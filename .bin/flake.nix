{
  description = "Nix flake for R/Python/shell development";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};

      # Base packages
      basePackages = with pkgs; [
        bashInteractive
        curl
        gettext
        gh
        git
        pandoc
        quarto
        R
        radianWrapper
        python312
      ];

      # Python packages
      pyPackages = with pkgs.python312Packages; [
        ipython
        jupyter
        openai
        requests
        google-api-python-client
        google-auth-oauthlib
        google-auth-httplib2
      ];

      # R packages
      rPackages = with pkgs.rPackages; [
        # Utils
        devtools
        knitr
        languageserver
        rmarkdown
        tidyverse
      ];

      allPackages = basePackages ++ rPackages ++ pyPackages;
    in {
      devShell = pkgs.mkShell {
        buildInputs = allPackages;
        shellHook = ''
          echo "Welcome to the development shell!"
          echo "You have access to the following tools:"
          echo "- R"
          echo "- Python"
          echo "- Jupyter"
          echo "- Quarto"
          echo "- Git"
          echo "- Pandoc"
          echo "Feel free to customize this shell further as needed."
        '';
      };
    });
}
