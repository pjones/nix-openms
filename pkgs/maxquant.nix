{
  stdenv,
  lib,
  requireFile,
  makeWrapper,
  dotnet-runtime,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "MaxQuant";
  version = "2.8.1.0";
  passthru.manual = true;

  src = requireFile rec {
    name = "MaxQuant_v${finalAttrs.version}.zip";
    sha256 = "04x0c29n6zcsz7srxwqhnc8nb2jsh3sc9n513wzw8v71xpb4qgqb";

    message = ''
      In order to use MaxQuant you must manually download the application from:

      https://maxquant.org/download_asset/maxquant/latest

      And then add the file to the Nix store:

      nix-prefetch-url file://\$PWD/${name}
    '';
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share/maxquant"
    cp -ar bin "$out/share/maxquant/"

    makeWrapper \
      "${lib.getExe dotnet-runtime}" \
      "$out/bin/MaxQuantCmd" \
      --add-flags "$out/share/maxquant/bin/MaxQuantCmd.dll"

    runHook postInstall
  '';

  meta = {
    description = "Quantitative proteomics software package";
    homepage = "https://maxquant.org/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ pjones ];
  };
})
