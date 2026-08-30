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
    cargoExtraArgs = "-p ayame -p ayame-stylekit";

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
      if [ -d qt/qml6/qml ]; then
        cp -r qt/qml6/qml/* $out/lib/qt-6/qml/Ayame/qml/
      fi
      qmldir_file=target/cxxqt/qml_modules/Ayame/qmldir
      if [ -f "$qmldir_file" ]; then
        cp "$qmldir_file" $out/lib/qt-6/qml/Ayame/qmldir
      fi
      qmltypes_file=target/cxxqt/qml_modules/Ayame/plugin.qmltypes
      if [ -f "$qmltypes_file" ]; then
        cp "$qmltypes_file" $out/lib/qt-6/qml/Ayame/plugin.qmltypes
      fi

      # StyleKit is an ordinary (non-style) QML module -- unlike Ayame, it
      # has no QT_QUICK_CONTROLS_STYLE naming/path constraint, so standard
      # Qt module install conventions apply. It's its own crate
      # (qt/stylekit), not part of qt/qml6, so its qmldir/qmltypes
      # are generated under a separate target/cxxqt/qml_modules/StyleKit/.
      mkdir -p $out/lib/qt-6/qml/StyleKit/qml/theme
      if [ -d qt/stylekit/qml/theme ]; then
        cp -r qt/stylekit/qml/theme/* $out/lib/qt-6/qml/StyleKit/qml/theme/
      fi
      stylekit_qmldir_file=target/cxxqt/qml_modules/StyleKit/qmldir
      if [ -f "$stylekit_qmldir_file" ]; then
        cp "$stylekit_qmldir_file" $out/lib/qt-6/qml/StyleKit/qmldir
      fi
      stylekit_qmltypes_file=target/cxxqt/qml_modules/StyleKit/plugin.qmltypes
      if [ -f "$stylekit_qmltypes_file" ]; then
        cp "$stylekit_qmltypes_file" $out/lib/qt-6/qml/StyleKit/plugin.qmltypes
      fi
    '';
  }
)
