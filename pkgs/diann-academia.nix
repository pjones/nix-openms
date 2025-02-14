{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, unzip
}:

stdenv.mkDerivation rec {
  pname = "DIA-NN-Academia";
  version = "2.0";

  src = fetchurl {
    url = "https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-${version}-Academia-Linux.zip";
    hash = "sha256-Ir8gxbMe77EXEHRaJGv8BbP6rbmer4mk5WxaT7YU95E=";
  };

  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/lib"
    install --mode=0555 diann-linux "$out/bin/diann"

    while IFS= read -r -d "" file; do
      install --mode=0555 "$file" "$out/lib"
    done < <(find . -type f -name 'lib*' -print0)

    runHook postInstall
  '';

  meta = with lib; {
    # Closed source software:
    # https://objects.githubusercontent.com/github-production-release-asset-2e65be/125283280/879549c5-5178-477a-bf14-85fc61685173?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250214%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250214T113611Z&X-Amz-Expires=300&X-Amz-Signature=b002a2b45ae1f28776281d9d5e67c0e7b30973ba2f9fe02d69fe373470e838e5&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DLICENSE.txt&response-content-type=application%2Foctet-stream
    license = "proprietary";

    homepage = "https://github.com/vdemichev/DiaNN";
    description = "Universal automated software suite for DIA proteomics data analysis";
    platforms = platforms.linux;
    maintainers = with maintainers; [ pjones ];
  };
}
