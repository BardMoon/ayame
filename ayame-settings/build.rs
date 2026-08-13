use cxx_qt_build::{CxxQtBuilder, QmlFile, QmlModule};

fn main() {
    println!("cargo:rerun-if-changed=qml");
    println!("cargo:rerun-if-changed=src/cxxqt_object.rs");

    CxxQtBuilder::new_qml_module(QmlModule::new("org.ayame.settings").qml_files([
        QmlFile::from("qml/main.qml"),
        QmlFile::from("qml/pages/GeneralPage.qml"),
        QmlFile::from("qml/pages/DecorationPage.qml"),
        QmlFile::from("qml/pages/ExceptionsPage.qml"),
    ]))
    .files(["src/cxxqt_object.rs"])
    .qt_module("Quick")
    .qt_module("QuickControls2")
    .build();
}
