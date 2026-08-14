# Fix: controls collapse to 0x0 (missing implicitWidth/implicitHeight)

## Root cause

Commit `901cdd1` ("use QtQuick.Templates as T") switched every widget in
`crates/qml6/qml/widgets/**` from subclassing `QtQuick.Controls`
(`QQC2.<Control> { ... }`, which inherited implicit sizing "for free"
from whatever style was active) to subclassing `QtQuick.Templates`
(`T.<Control> { ... }`) directly. `T.Control`/`T.Container` do **not**
compute `implicitWidth`/`implicitHeight` from `contentItem`/`indicator`/
`background` automatically -- every real QQC2 style (Basic, Fusion,
Material, qqc2-breeze-style) has to bind this explicitly in every single
control file, via the standard formula:

```qml
implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                         implicitContentWidth + leftPadding + rightPadding)
implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding,
                          implicitBackgroundHeight + topInset + bottomInset)
```

That binding only made it into a handful of files during the migration
(`Button.qml`, `Menu.qml` [special-cased contentItem width, see its own
comment], `Switch.qml`'s *indicator* only, `SwitchDelegate.qml`'s
*indicator* only, and the controls that already had partial sizing from
before). Everywhere else the control silently collapsed to 0x0 (or
0-width), which is invisible unless something external forces a size.
Reported symptoms all trace back to this:

- Toggle (`Switch`) overlapping neighboring elements: `Switch.qml`'s
  root has no `implicitWidth`/`implicitHeight`, only its `indicator`
  Rectangle does (36x20) -- that's the indicator's own size, not
  propagated to the control, so the control itself lays out as 0-width
  in a Row/Column and its indicator (positioned by `x`/`y`, not layout)
  visually overlaps whatever comes next.
- Delegates (`ItemDelegate`, `CheckDelegate`, `RadioDelegate`,
  `SwipeDelegate`) never showing: 0-height delegate rows in a
  ListView/list, invisible.
- Popup background transparent / popup sometimes not showing at all:
  `Popup.qml`, `Dialog.qml`, `Drawer.qml`, `ToolTip.qml`,
  `DialogButtonBox.qml` all missing implicit sizing -> 0x0 popup, its
  `background` Rectangle draws at 0x0 too (looks "transparent"/invisible).

Also found while auditing: `SwitchDelegate.qml`'s `contentItem` reserves
space for the indicator via `leftPadding: control.indicator.width +
control.spacing`, but the indicator is positioned on the *right*
(`x: control.width - width - control.rightPadding`) -- should be
`rightPadding`, not `leftPadding`, or the text can overlap/crowd the
switch on the right edge once sizing is fixed.

## Files needing the implicit-size fix

Reported-symptom files (fix first):
- [x] `crates/qml6/qml/widgets/controls/Switch.qml`
- [x] `crates/qml6/qml/widgets/delegates/ItemDelegate.qml`
- [x] `crates/qml6/qml/widgets/delegates/CheckDelegate.qml`
- [x] `crates/qml6/qml/widgets/delegates/RadioDelegate.qml`
- [x] `crates/qml6/qml/widgets/delegates/SwipeDelegate.qml`
- [x] `crates/qml6/qml/widgets/delegates/SwitchDelegate.qml` (+ fix
      leftPadding -> rightPadding on its contentItem)
- [x] `crates/qml6/qml/widgets/popups/Popup.qml`
- [x] `crates/qml6/qml/widgets/popups/Dialog.qml`
- [x] `crates/qml6/qml/widgets/popups/Drawer.qml`
- [x] `crates/qml6/qml/widgets/popups/ToolTip.qml`
- [x] `crates/qml6/qml/widgets/popups/DialogButtonBox.qml`

Same-bug sweep (rest of the affected controls, for consistency):
- [x] `crates/qml6/qml/widgets/buttons/AbstractButton.qml`
- [x] `crates/qml6/qml/widgets/buttons/RadioButton.qml`
- [x] `crates/qml6/qml/widgets/buttons/TabButton.qml`
- [x] `crates/qml6/qml/widgets/controls/CheckBox.qml`
- [x] `crates/qml6/qml/widgets/controls/Control.qml`
- [x] `crates/qml6/qml/widgets/controls/ComboBox.qml` (implicitWidth only; implicitHeight already present)
- [x] `crates/qml6/qml/widgets/containers/Container.qml`
- [x] `crates/qml6/qml/widgets/containers/Frame.qml`
- [x] `crates/qml6/qml/widgets/containers/Pane.qml`
- [x] `crates/qml6/qml/widgets/containers/GroupBox.qml`
- [x] `crates/qml6/qml/widgets/containers/Page.qml`
- [x] `crates/qml6/qml/widgets/containers/ScrollView.qml`
- [x] `crates/qml6/qml/widgets/containers/StackView.qml`
- [x] `crates/qml6/qml/widgets/containers/SwipeView.qml`
- [x] `crates/qml6/qml/widgets/containers/TabBar.qml`
- [x] `crates/qml6/qml/widgets/containers/ToolBar.qml`
- [x] `crates/qml6/qml/widgets/menus/MenuItem.qml`
- [x] `crates/qml6/qml/widgets/controls/Tumbler.qml`

Checked, not affected (confirmed OK, no change needed):
- `ApplicationWindow.qml` (top-level Window, not a Control -- sized by
  the app/WM, not by content)
- `TextField.qml`/`TextArea.qml` (implicit width comes from
  QQuickTextInput/QQuickTextEdit's own text metrics at the Templates
  level, not from an abstract contentItem -- only implicitHeight needs
  an explicit override, which they already have)
- `Label.qml`, `Menu.qml`, `Button.qml` and the rest of the files the
  initial grep showed nonzero implicit* counts on their *root* control
  (not just a child indicator/background) were already correct.

## Verification

- [ ] `cargo check -p ayame-qml6` (or project's normal build command)
      after edits, to catch QML property-binding typos build.rs might
      not catch until QML load, plus normal Rust compile check.
- [ ] If a running app/preview is available, visually confirm: Switch
      no longer overlaps neighbors, ListView delegates render, Popup/
      Menu/ToolTip/Dialog show with an opaque themed background.
