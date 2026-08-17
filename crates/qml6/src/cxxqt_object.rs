use std::ffi::CStr;
use std::pin::Pin;
use std::sync::Mutex;

use cxx_qt::CxxQtType;
use cxx_qt_lib::{QColor, QString};

/// The last `(mode, accent_hex)` passed to `apply_theme`, so a freshly
/// constructed `ThemeSettings` (e.g. when the settings screen is opened)
/// can seed its displayed value from what was actually applied at startup
/// (`origami::apply_saved_theme_mode()`, or this crate's own
/// `apply_saved_settings()`, both call `apply_theme` with the persisted
/// settings before any QML loads) instead of missing an update that
/// happened without going through `ayamerc` at all. Takes priority over
/// `ayame-config` in `ThemeSettingsRust::default()` below for exactly that
/// reason -- it reflects this process's live state, which `ayamerc` alone
/// can't when something applied a value without saving it.
static LAST_APPLIED_THEME: Mutex<Option<(String, String)>> = Mutex::new(None);

// ayame-icons is a dependency purely for its build.rs side effect (bundling
// the Tabler Icons Qt resource -- see crates/icons). Nothing here calls into
// it at the Rust level, and without *some* real reference, rustc drops the
// never-referenced rlib (and therefore its linked-in Qt resource) from the
// final binary entirely -- this keeps it alive. Confirmed by testing: the
// vendored icons fail to link with this line removed.
const _KEEP_AYAME_ICONS_LINKED: &[(&str, &str)] = ayame_icons::MAPPING;

// ayame-stylekit is a separate crate purely so its QML plugin (the
// "StyleKit" module Ayame's own widgets import) is a distinct, swappable
// QML module name -- see crates/stylekit/build.rs. cxx-qt-build's QML
// module registration is a Rust-level static initializer: it only runs if
// something actually links the crate, which a plain `import StyleKit` in
// QML does not cause on its own. Same fix as _KEEP_AYAME_ICONS_LINKED
// above, same reason.
const _KEEP_AYAME_STYLEKIT_LINKED: &str = ayame_stylekit::MARKER;

fn last_applied_theme() -> Option<(String, String)> {
    LAST_APPLIED_THEME.lock().ok()?.clone()
}

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

/// `cettila_apply_theme_palette`'s `mode` parameter is now just a binary
/// "apply the given colors" (1) vs. "restore the captured system palette,
/// ignore the rest of the arguments" (0) flag -- preset *selection* fully
/// happens Rust-side via `ayame_colors::preset_by_id` before this is even
/// called, so C++ no longer needs to distinguish "light" from "dark" (or
/// now, from any of the many named-scheme ids) itself.
fn theme_mode_code(mode: &str) -> i32 {
    if mode == "system" { 0 } else { 1 }
}

/// Applies `mode` (`"system"`, or any flat scheme/variant id from
/// `ayame_colors::presets::SCHEMES`, e.g. `"dark"`/`"catppuccin-mocha"`)
/// composed with `accent_hex` ("#RRGGBB") as Ayame's own `QGuiApplication`
/// palette. A no-op unless Ayame is the currently active QQC2 style --
/// overriding the palette while e.g. Breeze is active would fight that
/// style's own, independently computed palette instead of leaving it alone
/// as intended.
pub fn apply_theme(mode: &str, accent_hex: &str) {
    if let Ok(mut last) = LAST_APPLIED_THEME.lock() {
        *last = Some((mode.to_string(), accent_hex.to_string()));
    }
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

/// Loads `ayamerc`, lets `mutate` change the `style` section, then saves it
/// back -- the read-modify-write shape each style object's `persist()`
/// qinvokable uses to commit its own current in-memory value(s) to disk.
/// Setters themselves only update in-memory state and (where applicable)
/// live-apply it; nothing reaches disk until `persist()` is called
/// explicitly (wired to the settings window's "Save" button), since each
/// QML-exposed object here is its own independent `QObject` with no shared
/// in-memory `Settings` instance to keep in sync.
fn persist_style(mutate: impl FnOnce(&mut ayame_config::StyleSettings)) {
    let mut settings = ayame_config::Settings::load();
    mutate(&mut settings.style);
    if let Err(e) = settings.save() {
        eprintln!("Failed to save Ayame settings: {e}");
    }
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

        #[qinvokable]
        fn persist(self: Pin<&mut StyleInfo>);

        #[qinvokable]
        fn reload(self: Pin<&mut StyleInfo>);

        #[qinvokable]
        fn reset_to_default(self: Pin<&mut StyleInfo>);

        #[qinvokable]
        fn default_saved_style(self: Pin<&mut StyleInfo>) -> QString;
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        type CornerRadiusSettings = super::CornerRadiusSettingsRust;

        #[qinvokable]
        fn option(self: Pin<&mut CornerRadiusSettings>) -> QString;

        #[qinvokable]
        fn set_option(self: Pin<&mut CornerRadiusSettings>, option: &QString);

        #[qinvokable]
        fn persist(self: Pin<&mut CornerRadiusSettings>);

        #[qinvokable]
        fn reload(self: Pin<&mut CornerRadiusSettings>);

        #[qinvokable]
        fn reset_to_default(self: Pin<&mut CornerRadiusSettings>);

        #[qinvokable]
        fn default_option(self: Pin<&mut CornerRadiusSettings>) -> QString;
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        type BorderWidthSettings = super::BorderWidthSettingsRust;

        #[qinvokable]
        fn option(self: Pin<&mut BorderWidthSettings>) -> QString;

        #[qinvokable]
        fn set_option(self: Pin<&mut BorderWidthSettings>, option: &QString);

        #[qinvokable]
        fn persist(self: Pin<&mut BorderWidthSettings>);

        #[qinvokable]
        fn reload(self: Pin<&mut BorderWidthSettings>);

        #[qinvokable]
        fn reset_to_default(self: Pin<&mut BorderWidthSettings>);

        #[qinvokable]
        fn default_option(self: Pin<&mut BorderWidthSettings>) -> QString;
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

        #[qinvokable]
        fn persist(self: Pin<&mut AnimationSettings>);

        #[qinvokable]
        fn reload(self: Pin<&mut AnimationSettings>);

        #[qinvokable]
        fn reset_to_default(self: Pin<&mut AnimationSettings>);

        #[qinvokable]
        fn default_speed_option(self: Pin<&mut AnimationSettings>) -> QString;

        #[qinvokable]
        fn default_enabled(self: Pin<&mut AnimationSettings>) -> bool;
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        type UiScaleSettings = super::UiScaleSettingsRust;

        #[qinvokable]
        fn scale(self: Pin<&mut UiScaleSettings>) -> f64;

        #[qinvokable]
        fn set_scale(self: Pin<&mut UiScaleSettings>, scale: f64);

        #[qinvokable]
        fn persist(self: Pin<&mut UiScaleSettings>);

        #[qinvokable]
        fn reload(self: Pin<&mut UiScaleSettings>);

        #[qinvokable]
        fn reset_to_default(self: Pin<&mut UiScaleSettings>);

        #[qinvokable]
        fn default_scale(self: Pin<&mut UiScaleSettings>) -> f64;
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

        // Newline-joined lists (same convention as StyleInfo's
        // available_styles) so SettingsPage.qml can build its
        // scheme -> variant two-stage picker without any C++ involved --
        // the whole registry is static Rust data in `ayame_colors::presets`.
        #[qinvokable]
        fn available_scheme_ids(self: Pin<&mut ThemeSettings>) -> QString;

        #[qinvokable]
        fn available_scheme_names(self: Pin<&mut ThemeSettings>) -> QString;

        #[qinvokable]
        fn available_variant_ids(self: Pin<&mut ThemeSettings>, scheme_id: &QString) -> QString;

        #[qinvokable]
        fn available_variant_names(self: Pin<&mut ThemeSettings>, scheme_id: &QString) -> QString;

        #[qinvokable]
        fn variant_name(
            self: Pin<&mut ThemeSettings>,
            scheme_id: &QString,
            variant_id: &QString,
        ) -> QString;

        // Which scheme a flat, persisted id belongs to (e.g.
        // "catppuccin-mocha" -> "catppuccin", "dark" -> "ayame"), or the
        // literal "system" if `id` is "system" -- lets SettingsPage.qml
        // derive its initial scheme/variant dropdown selection from
        // `mode()` alone.
        #[qinvokable]
        fn scheme_of(self: Pin<&mut ThemeSettings>, id: &QString) -> QString;

        #[qinvokable]
        fn default_accent_for(self: Pin<&mut ThemeSettings>, id: &QString) -> QColor;

        #[qinvokable]
        fn persist(self: Pin<&mut ThemeSettings>);

        #[qinvokable]
        fn reload(self: Pin<&mut ThemeSettings>);

        #[qinvokable]
        fn reset_to_default(self: Pin<&mut ThemeSettings>);

        #[qinvokable]
        fn default_mode(self: Pin<&mut ThemeSettings>) -> QString;

        #[qinvokable]
        fn default_accent_color(self: Pin<&mut ThemeSettings>) -> QColor;
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

        #[qinvokable]
        fn persist(self: Pin<&mut FontSettings>);

        #[qinvokable]
        fn reload(self: Pin<&mut FontSettings>);

        #[qinvokable]
        fn reset_to_default(self: Pin<&mut FontSettings>);

        #[qinvokable]
        fn default_family(self: Pin<&mut FontSettings>) -> QString;

        #[qinvokable]
        fn default_point_size(self: Pin<&mut FontSettings>) -> f64;
    }
}

pub struct StyleInfoRust {
    saved_style: String,
}

impl Default for StyleInfoRust {
    fn default() -> Self {
        Self {
            saved_style: ayame_config::Settings::load().style.saved_style,
        }
    }
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

    fn persist(self: Pin<&mut Self>) {
        let style = self.rust().saved_style.clone();
        persist_style(|s| s.saved_style = style);
    }

    fn reload(mut self: Pin<&mut Self>) {
        self.as_mut().rust_mut().saved_style = ayame_config::Settings::load().style.saved_style;
    }

    fn reset_to_default(mut self: Pin<&mut Self>) {
        self.as_mut().rust_mut().saved_style = ayame_config::StyleSettings::default().saved_style;
    }

    fn default_saved_style(self: Pin<&mut Self>) -> QString {
        QString::from(ayame_config::StyleSettings::default().saved_style.as_str())
    }
}

pub struct CornerRadiusSettingsRust {
    option: String,
}

impl Default for CornerRadiusSettingsRust {
    fn default() -> Self {
        Self {
            option: ayame_config::Settings::load().style.corner_radius,
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

    fn persist(self: Pin<&mut Self>) {
        let option = self.rust().option.clone();
        persist_style(|s| s.corner_radius = option);
    }

    fn reload(mut self: Pin<&mut Self>) {
        self.as_mut().rust_mut().option = ayame_config::Settings::load().style.corner_radius;
    }

    fn reset_to_default(mut self: Pin<&mut Self>) {
        self.as_mut().rust_mut().option = ayame_config::StyleSettings::default().corner_radius;
    }

    fn default_option(self: Pin<&mut Self>) -> QString {
        QString::from(ayame_config::StyleSettings::default().corner_radius.as_str())
    }
}

pub struct BorderWidthSettingsRust {
    option: String,
}

impl Default for BorderWidthSettingsRust {
    fn default() -> Self {
        Self {
            option: ayame_config::Settings::load().style.border_width,
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

    fn persist(self: Pin<&mut Self>) {
        let option = self.rust().option.clone();
        persist_style(|s| s.border_width = option);
    }

    fn reload(mut self: Pin<&mut Self>) {
        self.as_mut().rust_mut().option = ayame_config::Settings::load().style.border_width;
    }

    fn reset_to_default(mut self: Pin<&mut Self>) {
        self.as_mut().rust_mut().option = ayame_config::StyleSettings::default().border_width;
    }

    fn default_option(self: Pin<&mut Self>) -> QString {
        QString::from(ayame_config::StyleSettings::default().border_width.as_str())
    }
}

pub struct UiScaleSettingsRust {
    scale: f64,
}

impl Default for UiScaleSettingsRust {
    fn default() -> Self {
        Self {
            scale: ayame_config::Settings::load().style.ui_scale,
        }
    }
}

impl ffi::UiScaleSettings {
    fn scale(self: Pin<&mut Self>) -> f64 {
        self.rust().scale
    }

    fn set_scale(mut self: Pin<&mut Self>, scale: f64) {
        self.as_mut().rust_mut().scale = scale;
    }

    fn persist(self: Pin<&mut Self>) {
        let scale = self.rust().scale;
        persist_style(|s| s.ui_scale = scale);
    }

    fn reload(mut self: Pin<&mut Self>) {
        self.as_mut().rust_mut().scale = ayame_config::Settings::load().style.ui_scale;
    }

    fn reset_to_default(mut self: Pin<&mut Self>) {
        self.as_mut().rust_mut().scale = ayame_config::StyleSettings::default().ui_scale;
    }

    fn default_scale(self: Pin<&mut Self>) -> f64 {
        ayame_config::StyleSettings::default().ui_scale
    }
}

pub struct AnimationSettingsRust {
    speed_option: String,
    enabled: bool,
}

impl Default for AnimationSettingsRust {
    fn default() -> Self {
        let style = ayame_config::Settings::load().style;
        Self {
            speed_option: style.animation_speed,
            enabled: style.animations_enabled,
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

    fn persist(self: Pin<&mut Self>) {
        let speed_option = self.rust().speed_option.clone();
        let enabled = self.rust().enabled;
        persist_style(|s| {
            s.animation_speed = speed_option;
            s.animations_enabled = enabled;
        });
    }

    fn reload(mut self: Pin<&mut Self>) {
        let style = ayame_config::Settings::load().style;
        let mut rust = self.as_mut().rust_mut();
        rust.speed_option = style.animation_speed;
        rust.enabled = style.animations_enabled;
    }

    fn reset_to_default(mut self: Pin<&mut Self>) {
        let style = ayame_config::StyleSettings::default();
        let mut rust = self.as_mut().rust_mut();
        rust.speed_option = style.animation_speed;
        rust.enabled = style.animations_enabled;
    }

    fn default_speed_option(self: Pin<&mut Self>) -> QString {
        QString::from(ayame_config::StyleSettings::default().animation_speed.as_str())
    }

    fn default_enabled(self: Pin<&mut Self>) -> bool {
        ayame_config::StyleSettings::default().animations_enabled
    }
}

pub struct ThemeSettingsRust {
    mode: String,
    accent: String,
}

impl Default for ThemeSettingsRust {
    fn default() -> Self {
        // `LAST_APPLIED_THEME` wins when set -- it reflects whatever was
        // actually applied to this process (e.g. via `apply_saved_settings`
        // or Cettila's own `apply_saved_theme_mode`), which may be fresher
        // than what's on disk if something applied a value without saving
        // it. Otherwise fall back to `ayamerc` directly, so `ThemeSettings`
        // reflects the persisted pick even if nothing has called
        // `apply_theme` yet this process (previously this always started
        // from the hardcoded default -- see docs/roadmap.tm).
        match last_applied_theme() {
            Some((mode, accent)) => Self { mode, accent },
            None => {
                let style = ayame_config::Settings::load().style;
                Self {
                    mode: style.theme_mode,
                    accent: style.accent_color,
                }
            }
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

    fn available_scheme_ids(self: Pin<&mut Self>) -> QString {
        let joined = ayame_colors::presets::SCHEMES
            .iter()
            .map(|scheme| scheme.id)
            .collect::<Vec<_>>()
            .join("\n");
        QString::from(joined.as_str())
    }

    fn available_scheme_names(self: Pin<&mut Self>) -> QString {
        let joined = ayame_colors::presets::SCHEMES
            .iter()
            .map(|scheme| scheme.name)
            .collect::<Vec<_>>()
            .join("\n");
        QString::from(joined.as_str())
    }

    fn available_variant_ids(self: Pin<&mut Self>, scheme_id: &QString) -> QString {
        let joined = ayame_colors::presets::scheme_by_id(&scheme_id.to_string())
            .map(|scheme| {
                scheme
                    .variants
                    .iter()
                    .map(|variant| variant.id)
                    .collect::<Vec<_>>()
                    .join("\n")
            })
            .unwrap_or_default();
        QString::from(joined.as_str())
    }

    fn available_variant_names(self: Pin<&mut Self>, scheme_id: &QString) -> QString {
        let joined = ayame_colors::presets::scheme_by_id(&scheme_id.to_string())
            .map(|scheme| {
                scheme
                    .variants
                    .iter()
                    .map(|variant| variant.name)
                    .collect::<Vec<_>>()
                    .join("\n")
            })
            .unwrap_or_default();
        QString::from(joined.as_str())
    }

    fn variant_name(self: Pin<&mut Self>, scheme_id: &QString, variant_id: &QString) -> QString {
        let variant_id = variant_id.to_string();
        let name = ayame_colors::presets::scheme_by_id(&scheme_id.to_string())
            .and_then(|scheme| scheme.variants.iter().find(|v| v.id == variant_id))
            .map(|variant| variant.name)
            .unwrap_or_default();
        QString::from(name)
    }

    fn scheme_of(self: Pin<&mut Self>, id: &QString) -> QString {
        let id = id.to_string();
        if id == "system" {
            return QString::from("system");
        }
        QString::from(ayame_colors::scheme_of(&id).unwrap_or(""))
    }

    fn default_accent_for(self: Pin<&mut Self>, id: &QString) -> QColor {
        ayame_colors::default_accent_for(&id.to_string()).to_qcolor()
    }

    fn persist(self: Pin<&mut Self>) {
        let mode = self.rust().mode.clone();
        let accent = self.rust().accent.clone();
        persist_style(|s| {
            s.theme_mode = mode;
            s.accent_color = accent;
        });
    }

    fn reload(mut self: Pin<&mut Self>) {
        let style = ayame_config::Settings::load().style;
        apply_theme(&style.theme_mode, &style.accent_color);
        let mut rust = self.as_mut().rust_mut();
        rust.mode = style.theme_mode;
        rust.accent = style.accent_color;
    }

    fn reset_to_default(mut self: Pin<&mut Self>) {
        let style = ayame_config::StyleSettings::default();
        apply_theme(&style.theme_mode, &style.accent_color);
        let mut rust = self.as_mut().rust_mut();
        rust.mode = style.theme_mode;
        rust.accent = style.accent_color;
    }

    fn default_mode(self: Pin<&mut Self>) -> QString {
        QString::from(ayame_config::StyleSettings::default().theme_mode.as_str())
    }

    fn default_accent_color(self: Pin<&mut Self>) -> QColor {
        ayame_colors::RgbColor::from_hex(&ayame_config::StyleSettings::default().accent_color)
            .unwrap_or(ayame_colors::DEFAULT_ACCENT)
            .to_qcolor()
    }
}

pub struct FontSettingsRust {
    family: String,
    point_size: f64,
}

impl Default for FontSettingsRust {
    fn default() -> Self {
        let style = ayame_config::Settings::load().style;
        Self {
            family: style.font_family,
            point_size: style.font_point_size,
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

    fn persist(self: Pin<&mut Self>) {
        let family = self.rust().family.clone();
        let point_size = self.rust().point_size;
        persist_style(|s| {
            s.font_family = family;
            s.font_point_size = point_size;
        });
    }

    fn reload(mut self: Pin<&mut Self>) {
        let style = ayame_config::Settings::load().style;
        apply_ui_font(
            (!style.font_family.is_empty()).then_some(style.font_family.as_str()),
            style.font_point_size,
        );
        let mut rust = self.as_mut().rust_mut();
        rust.family = style.font_family;
        rust.point_size = style.font_point_size;
    }

    fn reset_to_default(mut self: Pin<&mut Self>) {
        let style = ayame_config::StyleSettings::default();
        apply_ui_font(
            (!style.font_family.is_empty()).then_some(style.font_family.as_str()),
            style.font_point_size,
        );
        let mut rust = self.as_mut().rust_mut();
        rust.family = style.font_family;
        rust.point_size = style.font_point_size;
    }

    fn default_family(self: Pin<&mut Self>) -> QString {
        QString::from(ayame_config::StyleSettings::default().font_family.as_str())
    }

    fn default_point_size(self: Pin<&mut Self>) -> f64 {
        ayame_config::StyleSettings::default().font_point_size
    }
}
