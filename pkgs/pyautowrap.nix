{ lib
, python3Packages
, fetchPypi
}:

python3Packages.buildPythonPackage rec {
  pname = "autowrap";
  version = "0.22.11";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tGy+HysmV2mDzYWQaBpJ626M5vKCp69q/s5RsjruYrc=";
  };

  build-system = with python3Packages;[
    setuptools
  ];

  dependencies = with python3Packages; [
    cython
  ];
}
