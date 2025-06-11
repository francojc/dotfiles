{
  description = "Nix flake for R/Python/shell development";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
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
      ];

      # Python environment with packages
      python = pkgs.python312.withPackages pythonPackages;

      # Python packages
      pythonPackages = ps:
        with ps; [
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

      allPackages = basePackages ++ rPackages ++ [python];
    in {
      devShell = pkgs.mkShell {
        buildInputs = allPackages;
        shellHook = ''
          export R_LIBS_USER=$PWD/R/Library;
          mkdir -p "$R_LIBS_USER";
          export PATH=$PATH:${python}/bin;
        '';
      };
    });
}
