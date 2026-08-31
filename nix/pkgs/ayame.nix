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

    outputHashes = {
      "git+https://github.com/BardMoon/origami-frameworks?rev=4a290a82f3cdcf85352af2046143bd86318bd065#4a290a82f3cdcf85352af2046143bd86318bd065" = "sha256-KlAn7kqBJTj8fRtMsCKXTKOk2FuWYtYCTrW2PEUoYrg=";
      "git+https://github.com/BardMoon/cxx-qt?branch=fix/qmlls-ini-readonly-source#01719cd4d22dd404d30dec36ff4bec9dc1bf099b" = "sha256-W2GCy2vc1sy+By12q8SkjehJTTF79BR1+QjHbQ/tACA=";
    };

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

      mkdir -p $out/lib/qt-6/qml/StyleKit/qml/theme
      if [ -d crates/stylekit/qml/theme ]; then
        cp -r crates/stylekit/qml/theme/* $out/lib/qt-6/qml/StyleKit/qml/theme/
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
