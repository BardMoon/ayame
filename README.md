
# Ayame

A custom Qt Quick Controls 2 style ("Ayame"), plus a handful of
supporting crates (persisted settings, color presets, bundled icons)
shared with sibling apps in this workspace's neighboring repos
(`../hime`, `../typedmark`, `../cettila`, `../origami-frameworks`). See
`docs/architecture.md` for the workspace layout.

## Icons

UI icons are bundled at build time (Tabler Icons, MIT-licensed) rather
than resolved against whatever icon theme happens to be installed on
the host OS -- this is what keeps icon rendering consistent across
Linux/Windows/macOS and across QQC2 styles. See
`docs/bundled-icons.md`.

## Qt Theme

- https://invent.kde.org/plasma/breeze
- https://github.com/kde/breeze
- https://invent.kde.org/plasma/qqc2-breeze-style
