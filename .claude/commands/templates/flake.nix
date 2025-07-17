{
  description = "Academic project development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
      
      # Core packages for academic work
      corePackages = with pkgs; [
        git
        pandoc
        quarto
        texlive.combined.scheme-full
      ];
      
      # R packages for data analysis
      rPackages = with pkgs; [
        R
        rPackages.tidyverse
        rPackages.rmarkdown
        rPackages.knitr
        rPackages.here
        rPackages.targets
        rPackages.testthat
        rPackages.roxygen2
      ];
      
      # Python packages for computational work
      pythonPackages = with pkgs; [
        python3
        python3Packages.pandas
        python3Packages.numpy
        python3Packages.matplotlib
        python3Packages.jupyter
        python3Packages.seaborn
        python3Packages.scikit-learn
        python3Packages.pytest
        ruff
      ];
      
      # Development tools
      devTools = with pkgs; [
        direnv
        docker
        docker-compose
      ];
      
      allPackages = corePackages ++ rPackages ++ pythonPackages ++ devTools;
    in {
      devShell = pkgs.mkShell {
        buildInputs = allPackages;
        
        shellHook = ''
          echo "Academic project environment loaded"
          echo "Core tools: git, pandoc, quarto, LaTeX"
          echo "R: tidyverse ecosystem with targets workflow"
          echo "Python: data science stack with ruff formatting"
          echo "Use 'direnv allow' to auto-load this environment"
        '';
      };
    });
}