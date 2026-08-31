use cxx_qt_build::{CxxQtBuilder, QmlFile, QmlModule};
use std::path::Path;

fn main() {
    println!("cargo:rerun-if-changed=qml");
    println!("cargo:rerun-if-changed=cpp");

    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    let cpp_dir = Path::new(&manifest_dir).join("cpp");

    CxxQtBuilder::new_qml_module(QmlModule::new("org.ayame.settings").qml_files([
        QmlFile::from("qml/main.qml"),
        QmlFile::from("qml/pages/GeneralPage.qml"),
        QmlFile::from("qml/pages/DecorationPage.qml"),
        QmlFile::from("qml/pages/AppearancePage.qml"),
        QmlFile::from("qml/pages/ExceptionsPage.qml"),
    ]))
    .qt_module("Quick")
    .qt_module("QuickControls2")
    .cpp_file(cpp_dir.join("app_bootstrap.h"))
    .cpp_file(cpp_dir.join("app_bootstrap.cpp"))
    .build();
}
