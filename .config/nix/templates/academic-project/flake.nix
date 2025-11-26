{
  description = "Academic project development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };

      pythonEnv = pkgs.python312.withPackages (ps: with ps; [
        pandas
        numpy
        matplotlib
        jupyter
        pytest
      ]);

      rEnv = pkgs.rWrapper.override {
        packages = with pkgs.rPackages; [
          tidyverse
          rmarkdown
          knitr
          here
          targets
          testthat
          roxygen2
        ];
      };

      corePackages = with pkgs; [
        git
        pandoc
        quarto
        typst
        tinymist
        ruff
      ];

      allPackages = corePackages ++ [ pythonEnv rEnv ];
    in {
      devShell = pkgs.mkShell {
        buildInputs = allPackages;

        shellHook = ''
          echo "Academic project environment loaded"
          echo "R: $(R --version | head -1)"
          echo "Python: $(python --version)"
          echo "Typst: $(typst --version)"
        '';
      };
    });
}
