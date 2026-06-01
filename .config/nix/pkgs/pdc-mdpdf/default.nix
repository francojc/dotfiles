{
  lib,
  stdenvNoCC,
  makeWrapper,
  bash,
  coreutils,
  pandoc,
  typst,
  # Check tools (only used in checkPhase)
  shellcheck,
  shfmt,
}:

stdenvNoCC.mkDerivation {
  pname = "pdc-mdpdf";
  version = "0.1.0";

  # Source is the package directory relative to this file
  src = ./.;

  nativeBuildInputs = [
    makeWrapper
  ];

  nativeCheckInputs = [
    shellcheck
    shfmt
  ];

  installPhase = ''
    runHook preInstall

    # Install scripts
    install -Dm755 bin/pdc-mdpdf "$out/bin/pdc-mdpdf"
    install -Dm755 bin/pdc-letter "$out/bin/pdc-letter"

    # Install shared data
    share="$out/share/pdc-mdpdf"
    mkdir -p "$share"
    cp -r templates defaults assets "$share/"

    # Process defaults files: substitute @share@ with actual store path
    for f in "$share"/defaults/*.yaml; do
      substituteInPlace "$f" \
        --subst-var-by share "$share"
    done

    # Fix shebangs (e.g., #!/usr/bin/env bash → Nix store bash)
    patchShebangs "$out/bin"

    # Wrap scripts with guaranteed PATH
    binPath="${lib.makeBinPath [ bash coreutils pandoc typst ]}"

    wrapProgram "$out/bin/pdc-mdpdf" \
      --prefix PATH : "$binPath" \
      --set PDC_MDPDF_SHARE "$share"

    wrapProgram "$out/bin/pdc-letter" \
      --prefix PATH : "$out/bin:$binPath" \
      --set PDC_MDPDF_SHARE "$share"

    runHook postInstall
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    shellcheck --severity=error bin/pdc-mdpdf bin/pdc-letter
    # shfmt -d is informational only; don't fail on formatting
    shfmt -d bin/pdc-mdpdf bin/pdc-letter || true
    runHook postCheck
  '';

  meta = with lib; {
    description = "Markdown to Typst PDF helper with Pandoc profiles";
    mainProgram = "pdc-mdpdf";
    platforms = platforms.darwin ++ platforms.linux;
    license = licenses.mit;
  };
}
