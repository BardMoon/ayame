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
      # The generated qmldir lists every component with the same
      # "qml/..." prefix build.rs's own widget_files/qml_files entries
      # use (e.g. "qml/widgets/menus/Menu.qml", relative to the qmldir
      # itself) -- so the QML source tree has to land at .../Ayame/qml/,
      # not flattened directly into .../Ayame/. Copying
      # crates/qml6/qml/* straight into the Ayame/ root (the previous
      # version of this script) stripped that "qml/" prefix, leaving
      # every single listed component unresolvable (confirmed with
      # qmllint: "listed as component in .../qmldir but does not exist"
      # for all 52 widget files) even once the module name/path
      # themselves were otherwise correct.
      mkdir -p $out/lib/qt-6/qml/QtQuick/Controls/Ayame/qml
      if [ -d crates/qml6/qml ]; then
        cp -r crates/qml6/qml/* $out/lib/qt-6/qml/QtQuick/Controls/Ayame/qml/
      fi
      # cxx-qt-build mirrors the module's dotted URI as a directory path
      # under target/cxxqt/qml_modules/ (e.g. "QtQuick.Controls.Ayame" ->
      # QtQuick/Controls/Ayame/qmldir), independent of the per-build
      # OUT_DIR hash -- deterministic, unlike `find target -name qmldir`
      # (which used to pick up whichever of several stale qmldir variants
      # `find` happened to list first, left over from this module's
      # naming history).
      qmldir_file=target/cxxqt/qml_modules/QtQuick/Controls/Ayame/qmldir
      if [ -f "$qmldir_file" ]; then
        cp "$qmldir_file" $out/lib/qt-6/qml/QtQuick/Controls/Ayame/qmldir
      fi
      # Not strictly required at runtime (Ayame's Rust-backed QML_ELEMENT
      # types self-register via cxx-qt's static plugin initializer once
      # linked into the consuming binary, not by Qt reading this file),
      # but qmllint/IDE tooling and qmldir's own `typeinfo` line expect
      # it to exist -- cheap to include, removes any doubt.
      qmltypes_file=target/cxxqt/qml_modules/QtQuick/Controls/Ayame/plugin.qmltypes
      if [ -f "$qmltypes_file" ]; then
        cp "$qmltypes_file" $out/lib/qt-6/qml/QtQuick/Controls/Ayame/plugin.qmltypes
      fi
    '';
  }
)
