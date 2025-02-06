{ dockerTools
, stdenv
, openms
, coreutils
, bash
}:

dockerTools.buildLayeredImage {
  name = "openms-buildenv";

  contents =
    [ bash coreutils stdenv.cc ]
    ++ openms.buildInputs
    ++ openms.nativeBuildInputs
    ++ openms.propagatedBuildInputs
    ++ openms.propagatedNativeBuildInputs;
}
