# Ayame workspace architecture

## Layout

- `crates/qml6` (package `ayame`) -- the "Ayame" QQC2 style itself
  (Rust + QML + cxx-qt bridge). The only piece that's actually a
  runtime style today; see `docs/qqc2-custom-style-resolution.md` for
  how Qt resolves its module name.
- `crates/colors` (`ayame-colors`) -- `QPalette` color data: presets
  (including several ported from third-party projects, credited in its
  own `README.md`) plus the logic to compose a preset with an accent
  color. Pure Rust, no cxx-qt bridge.
- `crates/config` (`ayame-config`) -- settings persisted to
  `~/.config/ayamerc`, shared between `crates/qml6` (reads it at
  startup/on change) and `ayame-settings` (the editor GUI below).
- `crates/icons` (`ayame-icons`) -- bundled Tabler Icons, exposed as a
  Qt resource at `qrc:/cettila/icons/<freedesktop-name>.svg`. See
  `docs/bundled-icons.md`.
- `crates/kdecoreation6`, `crates/kstyle6` -- stub directories for a
  future KDE window-decoration/style plugin; not implemented, commented
  out of the workspace `members` list.
- `ayame-settings` -- the standalone settings editor GUI (depends on
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
