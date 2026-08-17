use cxx_qt_build::{CxxQtBuilder, QmlFile, QmlModule};

fn main() {
    println!("cargo:rerun-if-changed=qml");

    // StyleKit -- the canonical, swappable theme-singleton module. Ayame's
    // own theme files are the (currently only) backing implementation.
    // Units.qml does `import Ayame 1.0 as Ayame` for its settings objects,
    // which is fine since both modules ship from the same package;
    // `.depends(["Ayame"])` just records this in the generated qmldir for
    // qmllint/qmlls.
    //
    // This is its own crate (not a second QmlModule registered from
    // crates/qml6's build.rs) because cxx-qt-build 0.9.1's
    // CxxQtBuilder::new_qml_module(...).build() cannot safely be called
    // twice within one build.rs -- both calls share the same per-crate qrc
    // output directory and resource-index numbering, so they race/collide
    // on the same `resources_0.qrc` path. One QmlModule per crate
    // (mirroring ayame-settings) sidesteps this entirely.
    //
    // No `.export()` here (unlike crates/qml6's "Ayame" module): export()
    // requires a `links` manifest key and is for exposing a C++/CMake
    // interface to downstream consumers, which nothing needs for this
    // pure-QML, no-native-bridge module -- ayame-settings's build.rs
    // (also QML-only-plus-app-glue, no downstream consumers) follows the
    // same no-export() pattern.
    CxxQtBuilder::new_qml_module(
        QmlModule::new("StyleKit")
            .qml_files([
                QmlFile::from("qml/theme/Units.qml").singleton(true),
                QmlFile::from("qml/theme/Theme.qml").singleton(true),
            ]),
    )
    .qt_module("Quick")
    .build();
}
