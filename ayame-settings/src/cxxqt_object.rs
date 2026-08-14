#[cxx_qt::bridge]
pub mod qobject {
    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(bool, draw_widget_borders)]
        #[qproperty(bool, animations_enabled)]
        #[qproperty(i32, animation_duration_ms)]
        #[qproperty(QString, shadow_size)]
        #[qproperty(i32, shadow_strength)]
        #[qproperty(i32, corner_radius)]
        #[qproperty(QString, border_size)]
        #[qproperty(QString, titlebar_alignment)]
        type AyameSettingsObject = super::AyameSettingsObjectRust;
    }

    unsafe extern "RustQt" {
        #[qinvokable]
        fn load(self: Pin<&mut AyameSettingsObject>);

        #[qinvokable]
        fn save(self: Pin<&mut AyameSettingsObject>);

        #[qinvokable]
        fn reset_defaults(self: Pin<&mut AyameSettingsObject>);
    }
}

use ayame_config::Settings;
use core::pin::Pin;
use cxx_qt::CxxQtType;
use cxx_qt_lib::QString;

pub struct AyameSettingsObjectRust {
    draw_widget_borders: bool,
    animations_enabled: bool,
    animation_duration_ms: i32,
    shadow_size: QString,
    shadow_strength: i32,
    corner_radius: i32,
    border_size: QString,
    titlebar_alignment: QString,
    inner_settings: Settings,
}

impl Default for AyameSettingsObjectRust {
    fn default() -> Self {
        let settings = Settings::load();
        Self {
            draw_widget_borders: settings.general.draw_widget_borders,
            animations_enabled: settings.general.animations_enabled,
            animation_duration_ms: settings.general.animation_duration_ms as i32,
            shadow_size: QString::from(&settings.decoration.shadow_size),
            shadow_strength: settings.decoration.shadow_strength as i32,
            corner_radius: settings.decoration.corner_radius as i32,
            border_size: QString::from(&settings.decoration.border_size),
            titlebar_alignment: QString::from(&settings.decoration.titlebar_alignment),
            inner_settings: settings,
        }
    }
}

impl qobject::AyameSettingsObject {
    pub fn load(mut self: Pin<&mut Self>) {
        let settings = Settings::load();
        self.as_mut()
            .set_draw_widget_borders(settings.general.draw_widget_borders);
        self.as_mut()
            .set_animations_enabled(settings.general.animations_enabled);
        self.as_mut()
            .set_animation_duration_ms(settings.general.animation_duration_ms as i32);
        self.as_mut()
            .set_shadow_size(QString::from(&settings.decoration.shadow_size));
        self.as_mut()
            .set_shadow_strength(settings.decoration.shadow_strength as i32);
        self.as_mut()
            .set_corner_radius(settings.decoration.corner_radius as i32);
        self.as_mut()
            .set_border_size(QString::from(&settings.decoration.border_size));
        self.as_mut()
            .set_titlebar_alignment(QString::from(&settings.decoration.titlebar_alignment));
        self.rust_mut().inner_settings = settings;
    }

    pub fn save(self: Pin<&mut Self>) {
        let mut settings = self.rust().inner_settings.clone();
        settings.general.draw_widget_borders = *self.draw_widget_borders();
        settings.general.animations_enabled = *self.animations_enabled();
        settings.general.animation_duration_ms = *self.animation_duration_ms() as u32;
        settings.decoration.shadow_size = self.shadow_size().to_string();
        settings.decoration.shadow_strength = *self.shadow_strength() as u32;
        settings.decoration.corner_radius = *self.corner_radius() as u32;
        settings.decoration.border_size = self.border_size().to_string();
        settings.decoration.titlebar_alignment = self.titlebar_alignment().to_string();

        if let Err(e) = settings.save() {
            eprintln!("Failed to save settings: {}", e);
        } else {
            println!("Ayame settings successfully saved to disk.");
        }
    }

    pub fn reset_defaults(mut self: Pin<&mut Self>) {
        let settings = Settings::default();
        self.as_mut()
            .set_draw_widget_borders(settings.general.draw_widget_borders);
        self.as_mut()
            .set_animations_enabled(settings.general.animations_enabled);
        self.as_mut()
            .set_animation_duration_ms(settings.general.animation_duration_ms as i32);
        self.as_mut()
            .set_shadow_size(QString::from(&settings.decoration.shadow_size));
        self.as_mut()
            .set_shadow_strength(settings.decoration.shadow_strength as i32);
        self.as_mut()
            .set_corner_radius(settings.decoration.corner_radius as i32);
        self.as_mut()
            .set_border_size(QString::from(&settings.decoration.border_size));
        self.as_mut()
            .set_titlebar_alignment(QString::from(&settings.decoration.titlebar_alignment));
        self.rust_mut().inner_settings = settings;
    }
}
