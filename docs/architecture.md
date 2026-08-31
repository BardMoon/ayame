# Ayame workspace architecture

## Layout

Split into `crates/` (genuinely Qt-free -- zero Qt dependency, buildable
without Qt installed at all) and `qt/` (requires Qt at build time). This
is organizational clarity only, not an enforcement mechanism -- what
actually keeps a `crates/` entry Qt-free is its own `Cargo.toml`
dependency edges, not which directory it lives in; double-check those
directly (a crate's own doc comments/README aren't reliable evidence
either -- `ayame-colors` used to claim Qt-free while still depending on
`cxx-qt-lib`, caught and fixed by reading its actual `Cargo.toml`).

`crates/` (Qt-free):
- `crates/colors` (`ayame-colors`) -- `QPalette` color data: presets
  (including several ported from third-party projects, credited in its
  own `README.md`) plus the logic to compose a preset with an accent
  color. Pure Rust, genuinely Qt-free (zero dependencies) -- it used to
  depend on `cxx-qt-lib` purely for two `QColor` conversion methods
  nothing outside `crates/qml6` called; those moved to `crates/qml6/src/
  cxxqt_object.rs` (`rgb_to_qcolor`/`rgb_from_qcolor`) so this crate can
  be depended on directly by non-Qt consumers (e.g. `../cettila`'s Slint
  app) without pulling in Qt at build time.
- `crates/config` (`ayame-config`) -- settings persisted to
  `~/.config/ayamerc`, shared between `crates/qml6` (reads it at
  startup/on change) and `crates/ayame-settings` (the editor GUI below).
- `crates/icons` (`ayame-icons`) -- bundled Tabler Icons, exposed as a
  Qt resource at `qrc:/cettila/icons/<freedesktop-name>.svg` behind a
  default-on `qt-resource` Cargo feature; a Qt-free consumer depends
  with `default-features = false` and resolves icons via `vendor_dir()`/
  `MAPPING` instead, no Qt at build time. See `docs/bundled-icons.md`.

`crates/` (Qt required at build time):
- `crates/qml6` (package `ayame`) -- the "Ayame" QQC2 style itself
  (Rust + QML + cxx-qt bridge). The only piece that's actually a
  runtime style today; see `docs/qqc2-custom-style-resolution.md` for
  how Qt resolves its module name.
- `crates/stylekit` (`ayame-stylekit`) -- `Theme`/`Units` QML singletons
  (`Theme.qml`/`Units.qml`), a distinct swappable QML module
  (`import StyleKit`) consumed by `../origami-frameworks`' widgets.
  Mid-migration onto `Qt.labs.StyleKit` under a separate task; may be
  retired later.
- `crates/kdecoreation6`, `crates/kstyle6` -- stub directories for a future KDE
  window-decoration/style plugin; not implemented, commented out of the
  workspace `members` list.
- `crates/ayame-settings` -- the standalone settings editor GUI (depends on
  `ayame` for the style itself, `ayame-config` for the persisted data).

## Consumers outside this workspace

Sibling repos (`../hime`, `../typedmark`, `../cettila`,
`../origami-frameworks`) depend on crates from here as external (git,
locally path-overridden for dev via each repo's own
`.cargo/config.toml`) dependencies -- `ayame` as their QQC2 style,
`ayame-icons` directly for icons without necessarily pulling in the
whole style. `../origami-frameworks`' `origami` crate is itself a
shared QML widget library (`ActionButtonGroup`, `Icon`, ...) that
`cettila` builds on; see `docs/bundled-icons.md` for how its `Icon.qml`
resolves against `ayame-icons`.
