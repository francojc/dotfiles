{
  description = "Data science project development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };

      pythonEnv = pkgs.python312.withPackages (ps: with ps; [
        # Core data science
        pandas
        numpy
        matplotlib
        seaborn
        scikit-learn

        # Jupyter
        jupyter
        ipython
        notebook

        # Additional
        pytest
        requests
        sqlalchemy
        plotly
      ]);

      devPackages = with pkgs; [
        git
        ruff
      ];
    in {
      devShell = pkgs.mkShell {
        buildInputs = devPackages ++ [ pythonEnv ];

        shellHook = ''
          echo "Data science environment loaded"
          echo "Python: $(python --version)"
          echo "Packages: pandas, numpy, matplotlib, scikit-learn"
        '';
      };
    });
}
