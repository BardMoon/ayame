# Bundled icons (`ayame-icons`)

## Why this exists

`QIcon::fromTheme()` resolution isn't guaranteed to hit a correctly
proportioned icon set outside a full desktop session -- Breeze's own
QQC2 style plugin (`qqc2-breeze-style`) gets this for free because it
links KIconThemes, which guarantees a sane Breeze fallback even without
a full Plasma session. Ayame has no such KDE Frameworks dependency, so
without help, `QIcon::fromTheme()` falls back to whatever theme (or
none) the desktop happens to have configured -- a differently drawn
icon set with far less internal padding than Breeze's can look
noticeably bigger at the same nominal pixel box. And on Windows, there
usually isn't a "breeze" theme installed at all, so *any* reliance on
OS icon-theme resolution is a dead end for an app that needs to run
there too.

The fix: stop depending on OS icon-theme resolution entirely. Icons are
vendored as actual SVG files and bundled into the binary as a Qt
resource, resolved by name directly (`qrc:/cettila/icons/<name>.svg`),
so rendering is byte-identical on Linux/Windows/macOS regardless of
active QQC2 style or desktop config.

## The package

`crates/icons` (package `ayame-icons`) is a small, mostly-native crate:

- `vendor/tabler-icons/outline/*.svg` -- SVG files vendored unmodified
  from [Tabler Icons](https://github.com/tabler/tabler-icons) (MIT),
  `outline` variant, pinned to a specific upstream commit (see
  `vendor/tabler-icons/NOTICE.md` for which one, and
  `vendor/tabler-icons/LICENSE` for the license text). Only the subset
  actually referenced by consumer apps is vendored, not the full
  ~5,900-icon set.
- `src/mapping.rs` -- `pub const MAPPING: &[(&str, &str)]`, a
  freedesktop-style name (`document-new`, `edit-delete`, ...) to Tabler
  filename (`file-plus`, `trash`, ...) table. Consumers only ever see
  the freedesktop-style names; the Tabler filename is an internal
  implementation detail. Every pick was made deliberately by reading
  the actual call site, not a mechanical rename -- Tabler's naming
  doesn't follow freedesktop convention at all. See
  `.agents/tasks/bundle-tabler-icons.md` in the workspace root for the
  full table and the reasoning behind each non-obvious pick.
- `build.rs` -- builds a `qt_build_utils::QResource` (prefix
  `/cettila/icons`) with one `QResourceFile` per mapping entry, source
  path `vendor/tabler-icons/outline/<tabler-name>.svg`, alias
  `<freedesktop-name>.svg`, then
  `CxxQtBuilder::new().qrc_resources(...).build().export()`. No QML
  module, no cxx-qt bridge -- this crate is Qt-resource-only.

Tabler Icons was picked over Breeze Icons specifically because this
package needs to be reusable by sibling apps that may not use Ayame's
QQC2 style at all (`../hime`, `../typedmark`, `../cettila`), and
Tabler's neutral outline style doesn't carry an OS-specific design
identity the way Breeze (KDE) or Fluent (Windows 11) do. Every vendored
SVG uses `stroke="currentColor"`, which is what makes
`IconImage.color`-based tinting work correctly regardless of load path
(see the bug below).

App logos are explicitly out of scope for this package -- each app
keeps its own logo in its own repo. This is for generic,
freedesktop-named, tintable UI icons only.

## Using it from a consumer app

Add `ayame-icons` as a normal Cargo dependency; its `build.rs` compiles
and links the Qt resource in, no wiring needed in the consumer's own
`build.rs`.

**A plain `Cargo.toml` dependency is not enough by itself, though.**
`ayame-icons` exports nothing at the Rust level beyond
`pub const MAPPING` (all the real work is build-script side effects) --
if nothing in the dependent crate's Rust source actually references
anything from it, rustc treats the whole crate as unused and silently
drops its rlib, and with it the linked-in Qt resource, from the final
binary. `cargo build` reports success either way; the only symptom is
icons failing to resolve at runtime. `crates/qml6/src/cxxqt_object.rs`
has:

```rust
const _KEEP_AYAME_ICONS_LINKED: &[(&str, &str)] = ayame_icons::MAPPING;
```

purely for this reason. Any other direct consumer of `ayame-icons`
needs the same kind of token reference somewhere in its own Rust
source (a transitive dependency, like `ayame-settings` depending on
`ayame` which depends on `ayame-icons`, is fine without one -- only the
crate that's the *first* real Rust-level consumer in the chain needs
it).

## QML side: `Icon.qml`

Ayame's own `crates/qml6` has no `Icon.qml` and no `icon.name`/`icon.source`
usage anywhere in its QML (its `IconLabel.qml`, backing
`Button`/`ToolButton`/etc.'s icon slot, only ever reads
`control.icon.source`, never `.name`, so it was never in scope here).

The actual icon-name -> pixmap resolution for every consumer across
this whole family of repos goes through exactly one file:
`origami-frameworks/origami/qml/widgets/controls/Icon.qml` (confirmed
by grepping every repo for `QtQuick.Controls.impl`/`CI.IconImage`
imports -- it's the only hit). Both `origami-frameworks`' own widgets
(`ActionButtonGroup`, `ToggleButton`, `ToggleGroup`, `IconStack`, ...)
and `cettila`'s custom `Icon`/`Action`/`ToggleButton`/`DropdownButton`
vocabulary route through it.

It wraps a child `CI.IconImage` (composition, not inheritance -- see
the file's own comment for why: `CI.IconImage` already has a `source`
url property, and this component's own public `source` means a
freedesktop-style *name*, which can't share one property identifier on
the same object once aliased) and sets only the child's `source`:

```qml
source: root.source.length > 0 ? "qrc:/cettila/icons/" + root.source + ".svg" : ""
```

`name` is deliberately left unset. An icon name without a
corresponding entry in `ayame-icons`' `MAPPING` renders blank rather
than falling back to a theme -- there is no OS theme fallback anywhere
in this design anymore (see "Removed: the Breeze fallback stopgap"
below), so any new icon name a consumer starts using must get a
mapping entry added at the same time.

### Bug found during rollout: `name` silently wins over `source`

The first version of this fix bound **both** `name: root.source` (kept
"as a fallback") and `source: "qrc:/cettila/icons/..."` on the same
`IconImage`, on the assumption that `QQuickIconImage` prefers a
non-empty `source` and only falls back to `name` if `source` fails to
load. That assumption was backwards: `QQuickIconImage` resolves via
`name`/`QIcon::fromTheme` whenever `name` is non-empty, unconditionally
-- `source` is only consulted when `name` is empty. Since `name` was
bound to the same value on every icon, it was *always* non-empty, so
`source` had no effect at all: every icon kept resolving through
whatever OS theme was installed (Breeze, in the environment this was
found in), completely unaffected by the new bundled resource. Real
symptom, not a hypothetical -- caught by running `origami-gallery` and
`cettila` and visually seeing Breeze icons instead of Tabler ones.
Fixed by removing the `name` binding entirely, per the snippet above.

### Bug found after that: the original inventory missed Rust-generated names

The initial `MAPPING` was built by grepping consumer QML for icon-name
literals (`iconName:`, `icon.name:`, bare `source:`), which covers
every *static* icon name but misses names computed dynamically in
Rust -- e.g. `origami-frameworks/origami/src/fs_entries.rs`'s
extension-to-icon-name function (`text-markdown`, `text-x-generic`,
`video-x-generic`, `application-pdf`), or `cettila`'s bookmarks-sidebar
folder icons (`user-home`, `user-desktop`, `folder-documents`,
`folder-download`, `folder-pictures`, `folder-videos`,
`folder-music`, `folder-bookmarks`). With no OS-theme fallback left,
these rendered blank at runtime (`QML IconImage: Cannot open:
qrc:/cettila/icons/text-x-generic.svg` and similar) instead of failing
loudly at build time -- caught by the user actually using the file
explorer/bookmarks sidebar, not by any of the checks above. Added to
`MAPPING` once found; see `src/mapping.rs` for the picks. When adding a
new consumer, grep *implementation* code for icon-name construction,
not just QML literals.

### Bug found after that: a third, smaller round of missed literals

Even the QML-literal inventory itself wasn't complete: `chevron-down`/
`chevron-right` (`PaneDrawer.qml`, `ViewTypePickerButton.qml`,
`ToggleGroup.qml`) and `arrow-left` (`CollapsiblePanel.qml`) were
missed by the original single-pass grep -- all inside ternaries
(`iconName: cond ? "a" : "b"`), which a naive "first string literal
after the property name" search silently drops the second branch of.
Found by re-running the audit with a line-based extraction (every
quoted string on any line containing `iconName:`/`icon.name:`/`icon:`,
not just the first match) across both `../origami-frameworks` and
`../cettila`, diffed against `MAPPING`'s existing keys. Also turned up
several false positives worth noting so they aren't "fixed" by
mistake: `block`/`memo`/`osm` come from `===` mode comparisons on the
*same line* as an icon ternary, not icon names themselves; `edit` and
`edit-rename` only ever appear inside a `//`-commented-out example.
If auditing this again, prefer that line-based, ternary-aware grep
over a first-match one.

## Removed: the Breeze fallback stopgap

Before this package existed, `crates/qml6/cpp/icon_theme.cpp` called
`QIcon::setFallbackThemeName("breeze")` at plugin load, as a stopgap so
`QIcon::fromTheme()` had *some* sane fallback on Linux. It never helped
on Windows (no "breeze" theme installed there), which was always the
real problem this whole package solves properly. Once `Icon.qml`
stopped depending on theme resolution for every name it knows about,
this stopgap became pure dead weight (and its Windows gap made it a
false sense of security besides), so it was deleted, along with its
registration in `crates/qml6/build.rs`.

## Windows

Nothing in this package uses a Linux-specific API: `qrc:/...` is a Qt
resource scheme with identical semantics on every platform Qt
supports, the vendored SVGs are plain files, and the Rust side uses
plain `std::path`/`PathBuf` joins (correct on Windows path separators)
with no shell-outs. Not run/built on an actual Windows machine as part
of building this package -- reviewed at the code level only.
