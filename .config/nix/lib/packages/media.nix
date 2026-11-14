# Media and mail tools shared by every host.
pkgs: let
  # Linux only: make sioyek's file dialog (`o`) use the XDG desktop portal
  # so it routes to Strata. On macOS the native Cocoa dialog is used as-is.
  sioyek =
    if pkgs.stdenv.isLinux
    then
      pkgs.sioyek.overrideAttrs (o: {
        qtWrapperArgs =
          (o.qtWrapperArgs or [])
          ++ [
            "--set"
            "QT_QPA_PLATFORMTHEME"
            "xdgdesktopportal"
          ];
      })
    else pkgs.sioyek;
in
  with pkgs; [
    aerc # Email client
    khal # Calendar
    pianobar # Pandora client
    vdirsyncer # CalDAV/CardDAV sync
    sioyek # PDF viewer (Linux: portal file dialog, see above)
  ]
