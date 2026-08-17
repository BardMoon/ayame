// This crate's content is QML (see build.rs) -- the StyleKit module has
// no Rust bridge objects of its own. `MARKER` exists only so a real
// reference to this crate survives cargo's dead-code elimination: without
// one, nothing pulls this rlib into the final link, and StyleKit's QML
// plugin (cxx-qt-build's static initializer, matching how "Ayame" itself
// only works because something links `ayame`) never registers -- see
// ayame's own crates/qml6/src/cxxqt_object.rs for the reference site and
// the identical `ayame-icons` precedent for this pattern.
pub const MARKER: &str = "ayame-stylekit";
