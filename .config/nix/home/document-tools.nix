{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.documentTools;
in {
  options.custom.documentTools = {
    enable = lib.mkEnableOption "personal document conversion tools";

    defaultProfile = lib.mkOption {
      type = lib.types.str;
      default = "wfu-letter";
      description = "Default pdc-mdpdf profile to use when --profile is not specified.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.pdc-mdpdf
    ];

    home.sessionVariables = {
      PDC_MDPDF_DEFAULT_PROFILE = cfg.defaultProfile;
    };

    # Pandoc reads its user data directory from $XDG_DATA_HOME/pandoc
    # (~/.local/share/pandoc by default). Dropping the Lua filter under
    # filters/ and the defaults file under defaults/ makes both available by
    # bare name from any directory:
    #
    #   pandoc in.docx --defaults=docx-clean
    #   pandoc in.docx -L docx-clean.lua
    #
    # xdg.dataFile is not gated on xdg.enable; it only needs xdg.dataHome,
    # which defaults to $HOME/.local/share.
    xdg.dataFile = {
      "pandoc/filters/docx-clean.lua".source = ./document-tools/pandoc/filters/docx-clean.lua;
      "pandoc/defaults/docx-clean.yaml".source = ./document-tools/pandoc/defaults/docx-clean.yaml;
    };
  };
}
