use std::ffi::CStr;
use std::pin::Pin;

use cxx_qt::CxxQtType;
use cxx_qt_lib::QString;

unsafe extern "C" {
    fn cettila_available_styles_joined() -> *mut std::os::raw::c_char;
    fn cettila_current_style_name() -> *mut std::os::raw::c_char;
    fn cettila_free_style_query_string(s: *mut std::os::raw::c_char);
}

unsafe extern "C" {
    fn cettila_apply_theme_mode(mode: i32);
}

unsafe extern "C" {
    fn cettila_available_font_families_joined() -> *mut std::os::raw::c_char;
    fn cettila_current_font_family() -> *mut std::os::raw::c_char;
    fn cettila_current_font_point_size() -> f64;
    fn cettila_apply_ui_font(family: *const std::os::raw::c_char, point_size: f64);
    fn cettila_free_font_query_string(s: *mut std::os::raw::c_char);
}

pub fn apply_ui_font(family: Option<&str>, point_size: f64) {
    let family_cstring = family.and_then(|f| std::ffi::CString::new(f).ok());
    let family_ptr = family_cstring
        .as_ref()
        .map_or(std::ptr::null(), |c| c.as_ptr());
    unsafe { cettila_apply_ui_font(family_ptr, point_size) };
}

fn theme_mode_code(mode: &str) -> i32 {
    match mode {
        "light" => 1,
        "dark" => 2,
        _ => 0,
    }
}

pub fn apply_theme_mode(mode: &str) {
    unsafe { cettila_apply_theme_mode(theme_mode_code(mode)) };
}

unsafe fn take_c_string(ptr: *mut std::os::raw::c_char) -> String {
    if ptr.is_null() {
        return String::new();
    }
    let s = unsafe { CStr::from_ptr(ptr) }
        .to_string_lossy()
        .into_owned();
    unsafe { cettila_free_style_query_string(ptr) };
    s
}

fn available_styles_raw() -> String {
    unsafe { take_c_string(cettila_available_styles_joined()) }
}

fn current_style_raw() -> String {
    unsafe { take_c_string(cettila_current_style_name()) }
}

unsafe fn take_font_c_string(ptr: *mut std::os::raw::c_char) -> String {
    if ptr.is_null() {
        return String::new();
    }
    let s = unsafe { CStr::from_ptr(ptr) }
        .to_string_lossy()
        .into_owned();
    unsafe { cettila_free_font_query_string(ptr) };
    s
}

fn available_font_families_raw() -> String {
    unsafe { take_font_c_string(cettila_available_font_families_joined()) }
}

fn current_font_family_raw() -> String {
    unsafe { take_font_c_string(cettila_current_font_family()) }
}

#[cxx_qt::bridge]
mod ffi {
    unsafe extern "C++" {
        include!(<QtQml/qqmlregistration.h>);
    }

    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        type StyleInfo = super::StyleInfoRust;

        #[qinvokable]
        fn available_styles(self: Pin<&mut StyleInfo>) -> QString;

        #[qinvokable]
        fn current_style(self: Pin<&mut StyleInfo>) -> QString;

        #[qinvokable]
        fn saved_style(self: Pin<&mut StyleInfo>) -> QString;

        #[qinvokable]
        fn save_style(self: Pin<&mut StyleInfo>, style: &QString);
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        type CornerRadiusSettings = super::CornerRadiusSettingsRust;

        #[qinvokable]
        fn option(self: Pin<&mut CornerRadiusSettings>) -> QString;

        #[qinvokable]
        fn set_option(self: Pin<&mut CornerRadiusSettings>, option: &QString);
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        type BorderWidthSettings = super::BorderWidthSettingsRust;

        #[qinvokable]
        fn option(self: Pin<&mut BorderWidthSettings>) -> QString;

        #[qinvokable]
        fn set_option(self: Pin<&mut BorderWidthSettings>, option: &QString);
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        type AnimationSettings = super::AnimationSettingsRust;

        #[qinvokable]
        fn speed_option(self: Pin<&mut AnimationSettings>) -> QString;

        #[qinvokable]
        fn set_speed_option(self: Pin<&mut AnimationSettings>, option: &QString);

        #[qinvokable]
        fn enabled(self: Pin<&mut AnimationSettings>) -> bool;

        #[qinvokable]
        fn set_enabled(self: Pin<&mut AnimationSettings>, enabled: bool);
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        type UiScaleSettings = super::UiScaleSettingsRust;

        #[qinvokable]
        fn scale(self: Pin<&mut UiScaleSettings>) -> f64;

        #[qinvokable]
        fn set_scale(self: Pin<&mut UiScaleSettings>, scale: f64);
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        type ThemeSettings = super::ThemeSettingsRust;

        #[qinvokable]
        fn mode(self: Pin<&mut ThemeSettings>) -> QString;

        #[qinvokable]
        fn set_mode(self: Pin<&mut ThemeSettings>, mode: &QString);
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        type FontSettings = super::FontSettingsRust;

        #[qinvokable]
        fn available_families(self: Pin<&mut FontSettings>) -> QString;

        #[qinvokable]
        fn current_family(self: Pin<&mut FontSettings>) -> QString;

        #[qinvokable]
        fn current_point_size(self: Pin<&mut FontSettings>) -> f64;

        #[qinvokable]
        fn family(self: Pin<&mut FontSettings>) -> QString;

        #[qinvokable]
        fn set_family(self: Pin<&mut FontSettings>, family: &QString);

        #[qinvokable]
        fn point_size(self: Pin<&mut FontSettings>) -> f64;

        #[qinvokable]
        fn set_point_size(self: Pin<&mut FontSettings>, size: f64);
    }
}


#[derive(Default)]
pub struct StyleInfoRust {
    saved_style: String,
}

impl ffi::StyleInfo {
    fn available_styles(self: Pin<&mut Self>) -> QString {
        QString::from(available_styles_raw().as_str())
    }

    fn current_style(self: Pin<&mut Self>) -> QString {
        QString::from(current_style_raw().as_str())
    }

    fn saved_style(self: Pin<&mut Self>) -> QString {
        QString::from(self.rust().saved_style.as_str())
    }

    fn save_style(mut self: Pin<&mut Self>, style: &QString) {
        self.as_mut().rust_mut().saved_style = style.to_string();
    }
}

pub struct CornerRadiusSettingsRust {
    option: String,
}

impl Default for CornerRadiusSettingsRust {
    fn default() -> Self {
        Self {
            option: String::from("medium"),
        }
    }
}

impl ffi::CornerRadiusSettings {
    fn option(self: Pin<&mut Self>) -> QString {
        QString::from(self.rust().option.as_str())
    }

    fn set_option(mut self: Pin<&mut Self>, option: &QString) {
        self.as_mut().rust_mut().option = option.to_string();
    }
}

pub struct BorderWidthSettingsRust {
    option: String,
}

impl Default for BorderWidthSettingsRust {
    fn default() -> Self {
        Self {
            option: String::from("default"),
        }
    }
}

impl ffi::BorderWidthSettings {
    fn option(self: Pin<&mut Self>) -> QString {
        QString::from(self.rust().option.as_str())
    }

    fn set_option(mut self: Pin<&mut Self>, option: &QString) {
        self.as_mut().rust_mut().option = option.to_string();
    }
}

pub struct UiScaleSettingsRust {
    scale: f64,
}

impl Default for UiScaleSettingsRust {
    fn default() -> Self {
        Self { scale: 1.0 }
    }
}

impl ffi::UiScaleSettings {
    fn scale(self: Pin<&mut Self>) -> f64 {
        self.rust().scale
    }

    fn set_scale(mut self: Pin<&mut Self>, scale: f64) {
        self.as_mut().rust_mut().scale = scale;
    }
}

pub struct AnimationSettingsRust {
    speed_option: String,
    enabled: bool,
}

impl Default for AnimationSettingsRust {
    fn default() -> Self {
        Self {
            speed_option: String::from("normal"),
            enabled: true,
        }
    }
}

impl ffi::AnimationSettings {
    fn speed_option(self: Pin<&mut Self>) -> QString {
        QString::from(self.rust().speed_option.as_str())
    }

    fn set_speed_option(mut self: Pin<&mut Self>, option: &QString) {
        self.as_mut().rust_mut().speed_option = option.to_string();
    }

    fn enabled(self: Pin<&mut Self>) -> bool {
        self.rust().enabled
    }

    fn set_enabled(mut self: Pin<&mut Self>, enabled: bool) {
        self.as_mut().rust_mut().enabled = enabled;
    }
}

pub struct ThemeSettingsRust {
    mode: String,
}

impl Default for ThemeSettingsRust {
    fn default() -> Self {
        Self {
            mode: String::from("auto"),
        }
    }
}

impl ffi::ThemeSettings {
    fn mode(self: Pin<&mut Self>) -> QString {
        QString::from(self.rust().mode.as_str())
    }

    fn set_mode(mut self: Pin<&mut Self>, mode: &QString) {
        let mode_str = mode.to_string();
        self.as_mut().rust_mut().mode = mode_str.clone();
        apply_theme_mode(&mode_str);
    }
}

pub struct FontSettingsRust {
    family: String,
    point_size: f64,
}

impl Default for FontSettingsRust {
    fn default() -> Self {
        Self {
            family: String::new(),
            point_size: 0.0,
        }
    }
}

impl ffi::FontSettings {
    fn available_families(self: Pin<&mut Self>) -> QString {
        QString::from(available_font_families_raw().as_str())
    }

    fn current_family(self: Pin<&mut Self>) -> QString {
        QString::from(current_font_family_raw().as_str())
    }

    fn current_point_size(self: Pin<&mut Self>) -> f64 {
        unsafe { cettila_current_font_point_size() }
    }

    fn family(self: Pin<&mut Self>) -> QString {
        QString::from(self.rust().family.as_str())
    }

    fn set_family(mut self: Pin<&mut Self>, family: &QString) {
        let f = family.to_string();
        self.as_mut().rust_mut().family = f.clone();
        apply_ui_font(
            if f.is_empty() { None } else { Some(&f) },
            self.rust().point_size,
        );
    }

    fn point_size(self: Pin<&mut Self>) -> f64 {
        self.rust().point_size
    }

    fn set_point_size(mut self: Pin<&mut Self>, size: f64) {
        self.as_mut().rust_mut().point_size = size;
        let family = self.rust().family.clone();
        apply_ui_font(
            if family.is_empty() { None } else { Some(&family) },
            size,
        );
    }
}
