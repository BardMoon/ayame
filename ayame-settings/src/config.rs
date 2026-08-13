use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct GeneralSettings {
    pub draw_widget_borders: bool,
    pub animations_enabled: bool,
    pub animation_duration_ms: u32,
}

impl Default for GeneralSettings {
    fn default() -> Self {
        Self {
            draw_widget_borders: true,
            animations_enabled: true,
            animation_duration_ms: 200,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct DecorationSettings {
    pub shadow_size: String,
    pub shadow_strength: u32,
    pub corner_radius: u32,
    pub border_size: String,
    pub titlebar_alignment: String,
}

impl Default for DecorationSettings {
    fn default() -> Self {
        Self {
            shadow_size: "Medium".to_string(),
            shadow_strength: 60,
            corner_radius: 8,
            border_size: "Normal".to_string(),
            titlebar_alignment: "Center".to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ExceptionRule {
    pub property_type: String,
    pub property_match: String,
    pub hide_titlebar: bool,
    pub border_size: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq)]
pub struct Settings {
    pub general: GeneralSettings,
    pub decoration: DecorationSettings,
    pub exceptions: Vec<ExceptionRule>,
}

impl Settings {
    pub fn config_path() -> Option<PathBuf> {
        directories::ProjectDirs::from("org", "ayame", "ayame")
            .map(|proj| proj.config_dir().join("settings.toml"))
    }

    pub fn load() -> Self {
        if let Some(path) = Self::config_path() {
            if path.exists() {
                if let Ok(content) = fs::read_to_string(&path) {
                    if let Ok(settings) = toml::from_str(&content) {
                        return settings;
                    }
                }
            }
        }
        Self::default()
    }

    pub fn save(&self) -> anyhow::Result<()> {
        if let Some(path) = Self::config_path() {
            if let Some(parent) = path.parent() {
                fs::create_dir_all(parent)?;
            }
            let content = toml::to_string_pretty(self)?;
            fs::write(path, content)?;
        }
        Ok(())
    }
}
