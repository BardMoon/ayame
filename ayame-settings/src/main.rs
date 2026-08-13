mod config;
mod cxxqt_object;

use cxx_qt_lib::{QGuiApplication, QQmlApplicationEngine, QString, QUrl};

fn main() {
    // Ensure ayame crate and its Cxx-Qt static QML plugin initializers are linked
    std::hint::black_box(ayame::apply_theme_mode);

    let mut app = QGuiApplication::new();
    let mut engine = QQmlApplicationEngine::new();

    if let Some(mut engine) = engine.as_mut() {
        engine.as_mut().add_import_path(&QString::from("qrc:/qt/qml"));
        engine.as_mut().load(&QUrl::from("qrc:/qt/qml/org/ayame/settings/qml/main.qml"));
    }

    if let Some(app) = app.as_mut() {
        app.exec();
    }
}
