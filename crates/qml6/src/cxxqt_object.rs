use std::ffi::CStr;
use std::pin::Pin;

use cxx_qt::CxxQtType;
use cxx_qt_lib::{QColor, QString};

unsafe extern "C" {
    fn cettila_available_styles_joined() -> *mut std::os::raw::c_char;
    fn cettila_current_style_name() -> *mut std::os::raw::c_char;
    fn cettila_free_style_query_string(s: *mut std::os::raw::c_char);
}

unsafe extern "C" {
    #[allow(clippy::too_many_arguments)]
    fn cettila_apply_theme_palette(
        mode: i32,
        window: u32,
        window_text: u32,
        base: u32,
        alternate_base: u32,
        text: u32,
        button: u32,
        button_text: u32,
        highlight: u32,
        highlighted_text: u32,
        tooltip_base: u32,
        tooltip_text: u32,
        light: u32,
    );
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

/// Applies `mode` ("system"/"light"/"dark") composed with `accent_hex`
/// ("#RRGGBB") as Ayame's own `QGuiApplication` palette. A no-op unless
/// Ayame is the currently active QQC2 style -- overriding the palette while
/// e.g. Breeze is active would fight that style's own, independently
/// computed palette instead of leaving it alone as intended.
pub fn apply_theme(mode: &str, accent_hex: &str) {
    if current_style_raw() != "Ayame" {
        return;
    }
    let accent = ayame_colors::RgbColor::from_hex(accent_hex).unwrap_or(ayame_colors::DEFAULT_ACCENT);
    let preset = ayame_colors::preset_by_id(mode);
    let p = ayame_colors::compose_palette(preset, accent);
    unsafe {
        cettila_apply_theme_palette(
            theme_mode_code(mode),
            p.window.to_rgb_u32(),
            p.window_text.to_rgb_u32(),
            p.base.to_rgb_u32(),
            p.alternate_base.to_rgb_u32(),
            p.text.to_rgb_u32(),
            p.button.to_rgb_u32(),
            p.button_text.to_rgb_u32(),
            p.highlight.to_rgb_u32(),
            p.highlighted_text.to_rgb_u32(),
            p.tooltip_base.to_rgb_u32(),
            p.tooltip_text.to_rgb_u32(),
            p.light.to_rgb_u32(),
        )
    };
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

    unsafe extern "C++" {
        include!("cxx-qt-lib/qcolor.h");
        type QColor = cxx_qt_lib::QColor;
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

        #[qinvokable]
        fn accent_color(self: Pin<&mut ThemeSettings>) -> QColor;

        #[qinvokable]
        fn set_accent_color(self: Pin<&mut ThemeSettings>, color: &QColor);
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
    accent: String,
}

impl Default for ThemeSettingsRust {
    fn default() -> Self {
        Self {
            mode: String::from("auto"),
            accent: ayame_colors::DEFAULT_ACCENT.to_hex(),
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
        let accent = self.rust().accent.clone();
        apply_theme(&mode_str, &accent);
    }

    fn accent_color(self: Pin<&mut Self>) -> QColor {
        ayame_colors::RgbColor::from_hex(&self.rust().accent)
            .unwrap_or(ayame_colors::DEFAULT_ACCENT)
            .to_qcolor()
    }

    fn set_accent_color(mut self: Pin<&mut Self>, color: &QColor) {
        let hex = ayame_colors::RgbColor::from_qcolor(color).to_hex();
        self.as_mut().rust_mut().accent = hex.clone();
        let mode = self.rust().mode.clone();
        apply_theme(&mode, &hex);
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
            if family.is_empty() {
                None
            } else {
                Some(&family)
            },
            size,
        );
    }
}
