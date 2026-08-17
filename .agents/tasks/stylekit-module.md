# StyleKit: extract Theme/Units into their own QML module

Full design rationale: see `/home/tefla/.claude/plans/delegated-rolling-crown.md`
(plan-mode output from the session that designed this).

## Why

Origami maintains its own drifted copy of `Theme.qml`/`Units.qml`, which is
why Origami widgets' borders don't match what Ayame actually renders.
Fix: promote Ayame's canonical `Theme.qml`/`Units.qml` into an independently
-importable QML module, `StyleKit`, and have Origami depend on that instead
of its own copy. Breeze support not needed now; module is named independently
of "Ayame" so a Breeze-backed `StyleKit` could be added later without
touching Origami/Cettila code.

## Important deviation from the original plan

The plan originally called for registering `StyleKit` as a SECOND
`CxxQtBuilder::new_qml_module(...).build()` chain inside
`crates/qml6/build.rs`, alongside the existing `"Ayame"` chain. **This does
not work**: `cxx-qt-build` 0.9.1 panics ("Failed to write .qrc file for
Resources: ... No such file or directory") when `.build()` is called twice
in one build.rs, confirmed reproducible under `nix build .#ayame`.

Fix: `StyleKit` is its own crate, `crates/stylekit` (package
`ayame-stylekit`), with exactly one `QmlModule` registered in its own
`build.rs` -- mirroring `ayame-settings`'s pattern (one `QmlModule` per
crate). Its `build.rs` also does NOT call `.export()` (unlike qml6's
`"Ayame"` module) -- `.export()` requires a `links` manifest key and exists
to expose a C++/CMake interface to downstream consumers, which nothing
needs here.

Also hit, unrelated to StyleKit: `crates/icons/src/mapping.rs` had
uncommitted (but git-tracked-and-modified) changes referencing new icon
names whose backing SVGs under `crates/icons/vendor/tabler-icons/outline/`
were untracked -- invisible to the nix flake's git-based source filter,
so any package build failed trying to reference the missing files. Not
part of this task; just staged (`git add`, not committed) so the build
could proceed. If you see icon-related build failures again, check
`git status` for untracked vendor SVGs before assuming it's StyleKit-related.

## Steps

- [x] Created `crates/stylekit` crate (`Cargo.toml`, `build.rs`, stub
      `src/lib.rs`), registering `QmlModule::new("StyleKit").depends(["Ayame"])`
      with `qml/theme/Units.qml` + `qml/theme/Theme.qml` (moved here from
      `crates/qml6/qml/theme/` via `git mv`).
- [x] `crates/qml6/build.rs`: removed the two theme `QmlFile` entries from
      the `"Ayame"` module's `.qml_files([...])` list (files moved out, see
      above -- no second chain added here, see deviation above).
- [x] Root `Cargo.toml`: added `"crates/stylekit"` to workspace `members`.
- [x] `nix/pkgs/ayame.nix`: `cargoExtraArgs` now builds both `-p ayame -p
      ayame-stylekit`; added a `postInstall` block installing
      `$out/lib/qt-6/qml/StyleKit/{qmldir,plugin.qmltypes,qml/theme/{Theme,Units}.qml}`
      from `crates/stylekit/qml/theme/`.
- [x] `nix build .#ayame` passes. Confirmed
      `result/lib/qt-6/qml/StyleKit/qmldir` contains `singleton Units 1.0
      qml/theme/Units.qml`, `singleton Theme 1.0 qml/theme/Theme.qml`,
      `depends Ayame`, and `result/lib/qt-6/qml/Ayame/qml/theme/` is gone.

## Bug found after the fact: Ayame's own consumers were missed

Initial pass only migrated origami-frameworks/cettila's *external*
`Origami.Theme`/`Origami.Units` references and never checked whether
anything **inside `ayame` itself** referenced `Theme`/`Units`. It did: 53
files under `crates/qml6/qml/` (basically every widget --
`Button.qml`/`Label.qml`/`ComboBox.qml`/`TextField.qml`/`CheckBox.qml`/
`SpinBox.qml`/`Page.qml`/`HighlightRing.qml`/`TrackBar.qml`/etc.) and
`ayame-settings/qml/pages/AppearancePage.qml` referenced `Ayame.Theme`/
`Ayame.Units` (via their own `import Ayame 1.0 as Ayame`) -- since
Theme/Units moved out of the `"Ayame"` module into `"StyleKit"`, every one
of these went `undefined` at runtime (`TypeError: Cannot read property
'view' of undefined` etc.), breaking the entire style's actual rendering.
This was caught by the user pasting a runtime QML error log, not by any
verification step taken here -- `cargo check`/`nix build` never catch it,
since cross-module QML import resolution isn't validated at Rust build
time (see the note in the other repos' task files). **Lesson: when
splitting a QML singleton out of a module, grep the WHOLE package (not
just external consumer repos) for bare `<OldModuleAlias>.<SingletonName>`
references before considering the migration done.**

- [x] Migrated all 53 files: added `import StyleKit 1.0 as StyleKit` next
      to each file's existing `import Ayame 1.0 as Ayame`, rewrote
      `Ayame.Theme` -> `StyleKit.Theme` / `Ayame.Units` -> `StyleKit.Units`
      (word-boundary guarded -- confirmed `Ayame.ThemeSettings` in
      `AppearancePage.qml` was NOT touched).
- [x] `nix build .#ayame` and `nix build .#ayame-settings` both pass after
      the fix.

## Second bug found after the fact: StyleKit's plugin was never actually linked anywhere

Even after the above fix, `ayame-settings` still failed at runtime:
`module "StyleKit" plugin "StyleKit" not found`. Root cause, found by
actually running `ayame-settings` headlessly (`QT_QPA_PLATFORM=offscreen`;
Qt's QML load errors go to journald in this environment, not
stdout/stderr -- `journalctl --user --since <ts> -o cat`, not visible in
`cargo run`'s own output):

cxx-qt-build's `new_qml_module()` registers a QML module via a **Rust
static initializer**, not a real dlopen-able `.so` on disk (confirmed:
`find <ayame-package>/lib -iname "*.so*"` returns nothing at all, for
`Ayame` either). The "optional plugin" line in a generated qmldir is only
ever fulfilled by something *statically linking the crate as a real Cargo
dependency* -- the module then self-registers at process startup, before
QQmlApplicationEngine ever needs to search `QML_IMPORT_PATH` for a plugin
file. `Ayame` worked because `ayame-settings`/`origami`/etc. already
depend on the `ayame` crate for real Rust APIs (`apply_theme`, ...). Never
did that for `ayame-stylekit` -- nothing depended on it as a Cargo crate
anywhere, so its static initializer never ran, and there is no `.so` file
for Qt to fall back to finding on disk either. A plain `import StyleKit`
in QML is not enough on its own; QML_IMPORT_PATH runtime directory
scanning is a fallback path that doesn't really apply to this project's
Rust-linked apps at all.

Fix (see `_KEEP_AYAME_ICONS_LINKED` in `crates/qml6/src/cxxqt_object.rs`
for the pre-existing identical pattern this mirrors):
- [x] `crates/stylekit/src/lib.rs`: added `pub const MARKER: &str = "ayame-stylekit";`
      (previously empty -- needed something real to reference).
- [x] `crates/qml6/Cargo.toml` + root `Cargo.toml`'s `[workspace.dependencies]`:
      added `ayame-stylekit` as a real dependency of the `ayame` crate itself.
- [x] `crates/qml6/src/cxxqt_object.rs`: added
      `const _KEEP_AYAME_STYLEKIT_LINKED: &str = ayame_stylekit::MARKER;`
      next to the existing icons one.
- [x] Also removed `.depends(["Ayame"])` from `crates/stylekit/build.rs`
      during investigation (it emits a qmldir `depends Ayame` line with no
      version, which real qmldir syntax requires -- turned out NOT to be
      the cause, but left removed since it wasn't accomplishing anything
      real anyway; re-add if `qmllint`/`qmlls` cross-module hints turn out
      to matter later).
- [x] Verified headlessly: `ayame-settings` now runs with zero journald
      QML errors (previously crashed instantly with `loadQml failed`).
      Also verified `origami-gallery` (a separate binary, links `ayame`
      transitively via `origami`) the same way -- also clean. Did NOT
      launch `cettila`'s own GUI app (forbidden by its own AGENTS.md), but
      confirmed by code inspection that its link chain is real all the way
      down: `apps/desktop-qml/src/main.rs` calls `origami::apply_saved_theme_mode()`
      for real, `origami/src/lib.rs` calls `ayame::apply_theme()` for real,
      and `ayame` now calls `ayame_stylekit::MARKER` for real -- the same
      structural fix that already empirically worked for ayame-settings
      and origami-gallery.
- [ ] Once origami-frameworks + cettila sides are also migrated (separate
      task files in those repos), delete this file.
