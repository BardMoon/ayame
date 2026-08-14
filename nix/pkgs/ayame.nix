{
  craneLib,
  callPackage,

  #[ Dependencies ]
  pkg-config,
  cmake,
  qt6,
  llvmPackages,
}:
let
  src = ../..;
  qtToolchain = callPackage ../qt-toolchain.nix { inherit qt6; };
  commonArgs = rec {
    inherit src;
    pname = "ayame";
    version = "0.1.0";

    dontWrapQtApps = true;
    cargoExtraArgs = "-p ayame";

    nativeBuildInputs = [
      pkg-config
      cmake
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qmake
      llvmPackages.lld
    ];

    buildInputs = [
      qt6.qtbase
      qt6.qtdeclarative
    ];

    env = {
      ENV_QT_INCLUDE_PATH = "${qt6.qtdeclarative}/include";
      RUSTFLAGS = "-C link-arg=-fuse-ld=lld";
    };

    preBuild = ''
      export QMAKE="${qtToolchain.qmakeWrapper}/bin/qmake-wrapper"
      if [ -d target ]; then
        find target -type f -exec sed -i "s|/build/[^/]*source|$PWD|g" {} + 2>/dev/null || true
      fi
    '';
  };
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in
craneLib.buildPackage (
  commonArgs
  // {
    inherit cargoArtifacts;
    doCheck = false;
    postInstall = ''
      # A custom (non-built-in) QQC2 style is imported by Qt using its
      # style name literally as the QML import URI, with no
      # "QtQuick.Controls." prefix (see qtquickcontrols2plugin.cpp's own
      # styleUri(): that prefix is only added for Qt's own built-in
      # styles) -- so the module must be named/located as plain "Ayame",
      # not "QtQuick.Controls.Ayame". See docs/qqc2-custom-style-resolution.md.
      mkdir -p $out/lib/qt-6/qml/Ayame/qml
      if [ -d crates/qml6/qml ]; then
        cp -r crates/qml6/qml/* $out/lib/qt-6/qml/Ayame/qml/
      fi
      qmldir_file=target/cxxqt/qml_modules/Ayame/qmldir
      if [ -f "$qmldir_file" ]; then
        cp "$qmldir_file" $out/lib/qt-6/qml/Ayame/qmldir
      fi
      qmltypes_file=target/cxxqt/qml_modules/Ayame/plugin.qmltypes
      if [ -f "$qmltypes_file" ]; then
        cp "$qmltypes_file" $out/lib/qt-6/qml/Ayame/plugin.qmltypes
      fi
    '';
  }
)
