{ python3Packages
, openms
}:

python3Packages.buildPythonPackage {
  pname = "pyopenms";
  version = openms.version;
  format = "wheel";
  src = "${openms}/share/whl/${openms.passthru.wheelName}";
}
