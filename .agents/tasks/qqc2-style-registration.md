# Register Ayame as a real QQC2 style (QtQuick.Controls.Ayame)

Two independent bugs, both diagnosed via a real symptom (cettila's new
Explorer right-click context menu rendering ~5px wide, buttons invisible):

1. **Module-name regression**: commit `e553611` ("explicit-ayame-namespace")
   renamed the QML module from `"QtQuick.Controls.Ayame"` to plain
   `"Ayame"` in `build.rs`. `QT_QUICK_CONTROLS_STYLE=Ayame` (short-name
   style resolution) needs the module to be reachable as
   `QtQuick.Controls.Ayame` under `QtQuick/Controls/Ayame/` -- with the
   plain name, Qt's style plugin can't resolve it and every control
   silently falls back to Qt's stock "Basic" style.
   - That same commit ALSO (separately, a good change, keep it) switched
     every file's internal `Theme`/`Units`/settings-type self-reference
     from bare/unqualified to `import Ayame 1.0 as Ayame` + qualified
     `Ayame.Theme.foo`. Only the *module name string* inside that import
     needs to change (`Ayame 1.0` -> `QtQuick.Controls.Ayame 1.0`), the
     `as Ayame` alias and qualified-access style stay as they are.
   - One real bug from that commit: `buttons/AbstractButton.qml` has
     `Ayame.Ayame.Theme.view` (double-qualified) instead of `Ayame.Theme.view`.

2. **Wrong base classes (pre-existing, unrelated to the above commit)**:
   every widget file does `import QtQuick.Controls as QQC2` and roots
   itself as `QQC2.<Type> { ... }`. A real QQC2 style must subclass
   `QtQuick.Templates`'s `T.<Type>` instead -- subclassing `QQC2.<Type>`
   from inside what's supposed to BE that type's style delegate is
   self-referential (loading the style's own delegate re-triggers the
   same style lookup). Confirmed by comparing against the real
   `qqc2-breeze-style` package installed at
   `/nix/store/2klw7cmk6rpwmsf4czdda8bsa92bd3k9-qqc2-breeze-style-6.7.3`.

## Steps

1. [ ] `crates/qml6/build.rs`: `QmlModule::new("Ayame")` ->
   `QmlModule::new("QtQuick.Controls.Ayame")`, add
   `.depend("QtQuick.Controls")` (cxx-qt-build 0.9's `QmlModule::depend`
   API -- confirmed present in the vendored crate source).
2. [ ] `crates/qml6/qml/theme/Units.qml`, `crates/qml6/qml/theme/Theme.qml`:
   fix the self-referencing `import Ayame 1.0 as Ayame` -> `import
   QtQuick.Controls.Ayame 1.0 as Ayame` (module name only).
3. [ ] All 52 files under `crates/qml6/qml/widgets/**`:
   - `import QtQuick.Controls as QQC2` -> `import QtQuick.Templates as T`
   - `import Ayame 1.0 as Ayame` -> `import QtQuick.Controls.Ayame 1.0 as Ayame`
   - `QQC2.` -> `T.` everywhere in the file (base type + any enum access
     like `QQC2.Popup.Window`) EXCEPT `containers/ScrollView.qml`, which
     special-cases per Breeze's own ScrollView.qml (real ground truth,
     read on disk): the base type is `T.ScrollView`, but the composed
     `ScrollBar.vertical`/`.horizontal` attached-property qualifier AND
     the child `ScrollBar { ... }` instances stay BARE `ScrollBar`
     (same-module sibling-type resolution, no qualification at all --
     this is what lets them resolve to Ayame's own themed ScrollBar.qml
     rather than the unstyled Templates base).
   - Fix `buttons/AbstractButton.qml`'s `Ayame.Ayame.Theme` ->
     `Ayame.Theme` bug (both occurrences) while touching that file anyway.
4. [ ] `crates/qml6/qml/widgets/menus/Menu.qml`: add an explicit
   `implicitWidth` binding (Breeze's own pattern:
   `contentItem.visibleChildren.reduce((maxWidth, child) =>
   Math.max(maxWidth, child.implicitWidth), 0)`) -- `T.Menu`'s own
   default content `ListView` binds `implicitHeight: contentHeight` but
   never `implicitWidth`, so without this every `MenuItem`'s real text
   width is still invisible even after step 3's Templates fix.
5. [ ] Update the 3 external consumers found by grep across
   cettila + origami-frameworks:
   - `cettila/crates/views/settings/qml/SettingsPage.qml:6`
   - `origami-frameworks/origami/qml/theme/Units.qml:4`
   - `origami-frameworks/origami-gallery/qml/AyameWidgetsPage.qml:4`
   (module name only, keep each file's own `as X`/version convention.)
6. [ ] `nix/pkgs/ayame.nix`: drop the `la/cettila/Ayame` destination
   entirely (per explicit user instruction -- no consumer actually needs
   it, `la.cettila.Ayame` was a stale/historical naming attempt).
   `postInstall` should install only into
   `$out/lib/qt-6/qml/QtQuick/Controls/Ayame/`, and find the qmldir
   deterministically now that there's exactly one registered module (no
   more `find target -name qmldir | head -n1` ambiguity risk, but verify).
7. [ ] Build/verify: `cargo check -p ayame` (or whatever the qml6 crate's
   actual package name is) in the ayame repo; then `cargo check
   --workspace` in cettila (which path-depends on
   `origami-frameworks/ayame` -> this same source tree, so it recompiles
   too). Run `qmllint` on every touched .qml file. Read the generated
   qmldir to confirm `module QtQuick.Controls.Ayame` and `depends
   QtQuick.Controls` are both present.
8. [ ] Once confirmed working: revisit the `width: Units.gridUnit * N`
   workarounds added to cettila's `crates/views/explorer/qml/
   FileContextMenu.qml` and `DropActionMenu.qml` earlier this session
   (their own comments say "remove once Ayame Step 2 lands") -- decide
   whether to remove them now that real implicitWidth works again.
9. [ ] Delete this task file once done.
