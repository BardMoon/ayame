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
      mkdir -p $out/lib/qt-6/qml/QtQuick/Controls/Ayame
      if [ -d crates/qml6/qml ]; then
        cp -r crates/qml6/qml/* $out/lib/qt-6/qml/QtQuick/Controls/Ayame/
      fi
      # cxx-qt-build mirrors the module's dotted URI as a directory path
      # under target/cxxqt/qml_modules/ (e.g. "Ayame" ->
      # QtQuick/Controls/Ayame/qmldir), independent of the per-build
      # OUT_DIR hash -- deterministic, unlike `find target -name qmldir`
      # (which used to pick up whichever of several stale qmldir variants
      # `find` happened to list first, left over from this module's
      # naming history).
      qmldir_file=target/cxxqt/qml_modules/QtQuick/Controls/Ayame/qmldir
      if [ -f "$qmldir_file" ]; then
        cp "$qmldir_file" $out/lib/qt-6/qml/QtQuick/Controls/Ayame/qmldir
      fi
    '';
  }
)
