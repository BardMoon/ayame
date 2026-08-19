//! Generic, freedesktop-named, tintable UI icons bundled as vendored
//! Tabler Icons SVGs, so icon rendering is byte-identical across
//! Linux/Windows/macOS regardless of QQC2 style or desktop-installed
//! icon theme. Not app logos -- each app keeps its own in its own repo.
//!
//! The Qt resource itself (`qrc:/cettila/icons/<name>.svg`) is wired up
//! entirely in `build.rs`; this crate's Rust API is just [`MAPPING`].
//! See `../../docs/bundled-icons.md` for the full picture, including a
//! gotcha `build.rs` alone can't solve: depending on this crate from
//! Cargo isn't enough by itself for the resource to actually end up
//! linked into a consumer binary.

mod mapping;

pub use mapping::MAPPING;

#[used]
pub static MAPPING_STATIC: &[(&str, &str)] = mapping::MAPPING;
