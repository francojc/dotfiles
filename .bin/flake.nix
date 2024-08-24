{
  description = "Nix flake for R/Python/shell development";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # Base packages
        basePackages = with pkgs; [
          bashInteractive
          gettext
          gh
          git
          pandoc
          python312
          quarto
          R
          radianWrapper
        ];

        # Python packages
        pythonPackages = with pkgs.python312Packages; [
          openai
          requests
          json
        ];

        # R packages
        rPackages = with pkgs.rPackages; [
          # Utils
          devtools
          knitr
          languageserver
          rmarkdown
          # Project
          tidyverse
        ];

        allPackages = basePackages ++ rPackages ++ pythonPackages;
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = allPackages;
          shellHook = ''
            export R_LIBS_USER=$PWD/R/Library; mkdir -p $R_LIBS_USER;
          '';
        };
      });
}
