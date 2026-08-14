mod cxxqt_object;

use cxx_qt_lib::QGuiApplication;
use std::ffi::CString;

unsafe extern "C" {
    fn createEngine() -> u64;
    fn loadQml(engine_ptr: u64, qml_url_utf8: *const std::os::raw::c_char) -> bool;
    fn rootWindowOf(engine_ptr: u64) -> u64;
    fn destroyEngine(engine_ptr: u64);
}

fn main() {
    // Ensure ayame crate and its Cxx-Qt static QML plugin initializers are linked
    std::hint::black_box(ayame::apply_theme);

    let mut app = QGuiApplication::new();

    // Must run after QGuiApplication is constructed: apply_saved_settings()
    // -> apply_ui_font() touches QGuiApplication::font()/setFont(), which
    // need a live QGuiApplication instance (see cpp/font_query.cpp). Calling
    // it earlier seeds the app-wide default QFont from an uninitialized
    // QFont() (pointSizeF() == -1, no platform theme consulted yet), which
    // then propagates that -1 into every control's inherited font.
    ayame::apply_saved_settings();

    let qml_url = CString::new("qrc:/qt/qml/org/ayame/settings/qml/main.qml")
        .expect("qml_url contains null byte");
    let engine_ptr = unsafe { createEngine() };
    let load_ok = unsafe { loadQml(engine_ptr, qml_url.as_ptr()) };
    if !load_ok {
        panic!("loadQml failed. Check stderr for QML load errors.");
    }

    let window_ptr = unsafe { rootWindowOf(engine_ptr) };
    if window_ptr == 0 {
        panic!("rootWindowOf: root object is not a QQuickWindow");
    }

    if let Some(app) = app.as_mut() {
        app.exec();
    }

    unsafe {
        destroyEngine(engine_ptr);
    }
}
