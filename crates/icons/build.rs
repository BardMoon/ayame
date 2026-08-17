use cxx_qt_build::CxxQtBuilder;
use qt_build_utils::{QResource, QResourceFile, QResources};
use std::path::Path;

// Shared with src/mapping.rs (which this crate's library exposes as
// `ayame_icons::MAPPING`) -- included directly here because a build script
// cannot depend on its own crate's library.
include!("src/mapping.rs");

fn main() {
    println!("cargo:rerun-if-changed=vendor/tabler-icons/outline");

    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    let tabler_dir = Path::new(&manifest_dir).join("vendor/tabler-icons/outline");

    let icons = QResource::new()
        .prefix("/cettila/icons")
        .files(MAPPING.iter().map(|(freedesktop_name, tabler_name)| {
            QResourceFile::new(tabler_dir.join(format!("{tabler_name}.svg")))
                .alias(format!("{freedesktop_name}.svg"))
        }));

    CxxQtBuilder::new()
        .qrc_resources(QResources::new().resource(icons))
        .build()
        .export();
}
