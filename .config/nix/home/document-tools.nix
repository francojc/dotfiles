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
  };
}
