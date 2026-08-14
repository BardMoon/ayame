pub mod cxxqt_object;

pub use cxxqt_object::apply_theme;
pub use cxxqt_object::apply_ui_font;

/// Applies the persisted `ayamerc` theme + font eagerly, for host apps that
/// embed the Ayame QQC2 style standalone (without Cettila's own
/// `origami-config`-driven startup calling `apply_theme`/`apply_ui_font`
/// itself). A no-op unless Ayame is the currently active QQC2 style, same
/// as `apply_theme` itself.
pub fn apply_saved_settings() {
    let settings = ayame_config::Settings::load();
    apply_theme(&settings.style.theme_mode, &settings.style.accent_color);
    let family = (!settings.style.font_family.is_empty()).then_some(settings.style.font_family.as_str());
    apply_ui_font(family, settings.style.font_point_size);
}
