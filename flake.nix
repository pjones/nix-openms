{
  description = "OpenMS Package and Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Function to generate a set based on supported systems:
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Attribute set of nixpkgs for each system:
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
        });
    in
    {
      ##########################################################################
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};

          python3 = pkgs.python3.override {
            packageOverrides = final: prev: {
              autowrap = self.packages.${system}.pyautowrap;
              pyopenms = self.packages.${system}.pyopenms;
            };
          };
        in
        {
          inherit python3;
          default = self.packages.${system}.openms;

          buildenv = pkgs.callPackage pkgs/buildenv.nix {
            openms = self.packages.${system}.openms;
          };

          diann-academia = pkgs.callPackage pkgs/diann-academia.nix { };

          dockerimg = pkgs.callPackage pkgs/dockerimg.nix {
            openms = self.packages.${system}.openms;
          };

          openms = pkgs.callPackage pkgs/openms.nix {
            inherit python3;
            openmp = pkgs.llvmPackages_12.openmp;
            wrapQtAppsHook = pkgs.libsForQt5.qt5.wrapQtAppsHook;
          };

          pyautowrap = pkgs.callPackage pkgs/pyautowrap.nix { };

          pyopenms = pkgs.callPackage pkgs/pyopenms.nix {
            openms = self.packages.${system}.openms.override (_: {
              enablePython = true;
            });
          };

          rawfilereader = pkgs.callPackage pkgs/thermoraw/RawFileReader.nix { };

          thermorawfp = pkgs.callPackage pkgs/thermoraw/ThermoRawFileParser.nix {
            RawFileReader = self.packages.${system}.rawfilereader;
          };
        });

      ##########################################################################
      apps = forAllSystems (system: {
        thermorawfp = {
          type = "app";
          program = "${self.packages.${system}.thermorawfp}/bin/ThermoRawFileParser";
        };
      });

      ##########################################################################
      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = self.devShells.${system}.openms;

          openms = pkgs.mkShell {
            dontFixCmake = 1;
            cmakeFlags = self.packages.${system}.openms.cmakeFlags;

            inputsFrom = builtins.attrValues self.packages.${system};

            buildInputs = [
              (self.packages.${system}.python3.withPackages (pypkgs: with pypkgs; [
                black
                pyopenms
              ]))
            ];
          };

          quantms = pkgs.mkShell {
            buildInputs = [
              pkgs.nextflow
              pkgs.apptainer
            ];
          };
        });
    };
}
