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
    pname = "ayame-settings";
    version = "0.1.0";

    dontWrapQtApps = true;
    cargoExtraArgs = "-p ayame-settings";

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
  }
)
