pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

// Themed drop-in for QQC2's Popup, same "wrap the QQC2 type, replace its
// background" approach as widgets/Label.qml/widgets/inputs/TextField.qml.
// Four call sites (widgets/inputs/ToggleButton.qml's/ToggleGroup.qml's
// own detailsPopup, widgets/inputs/CollapsibleTextField.qml's
// collapsedPopup, pane/groups/PaneDrawer.qml's overlayPopup) had already
// hand-rolled this exact same background -- rounded rect, themed fill,
// a faint themed border -- independently of each other; this folds it
// into a shared default so a fifth call site (MapView.qml's pinEditor,
// previously left with zero override, just whatever the active QQC2
// style draws) picks it up too.
T.Popup {
    id: control

    // Same knob as widgets/Label.qml/widgets/inputs/CheckBox.qml.
    property int colorSet: Ayame.Theme.view

    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    // Opt-in: renders as a real top-level QWindow rather than an item
    // confined to the app's own QQuickWindow (the Popup.Item default this
    // stays on unless a call site asks otherwise). A Popup.Item popup gets
    // clipped at the app window's own edge no matter where it's positioned
    // (PaneDrawer.qml's overlayPopup hand-rolls _overlayWouldOverflow()/
    // _flip to work around that -- opts into detachedWindow: true instead,
    // as does pane/ViewTypePickerPopup.qml, the two call sites that
    // actually need to draw past that edge). Available since Qt 6.8 (this
    // codebase targets 6.11+).
    //
    // Needs Qt's Wayland QPA platform plugin (the qtwayland package) to be
    // present in the *running* environment, not just the build/dev one, or
    // a detached popup's window silently never receives keyboard input at
    // all -- mouse interaction (open/close/click) still works, so this is
    // easy to misdiagnose as a focus-handling bug in this app rather than
    // a missing system dependency (cost real debugging time here first --
    // see git history on this file/pane/ViewTypePickerPopup.qml/
    // pane/groups/PaneDrawer.qml for the false leads that came before
    // spotting the actual cause: qtwayland was in nix/dev.nix's buildInputs
    // but missing from nix/pkgs/cettila.nix's, so only the dev shell had
    // it). If a detached popup's content ever seems to accept clicks but
    // not typing again, check `qtwayland` is actually installed/on the
    // plugin path before suspecting this file.
    //
    // Left false everywhere except the two call sites above for an
    // unrelated, still-real reason: a detached Popup.Window closes the
    // instant the app loses OS-level window activation to *any* other
    // window, including a totally unrelated external application -- not
    // just "the user clicked elsewhere inside this app" (which
    // Popup.Item's own closePolicy already covers).
    // widgets/inputs/ToggleButton.qml's/ToggleGroup.qml's detailsPopup,
    // widgets/inputs/CollapsibleTextField.qml's collapsedPopup, and
    // MapView.qml's pinEditor are all meant to stay open across that kind
    // of external focus loss (e.g. alt-tabbing to check something else
    // mid-edit).
    property bool detachedWindow: false

    popupType: control.detachedWindow ? T.Popup.Window : T.Popup.Item

    padding: Ayame.Units.smallSpacing

    background: Rectangle {
        radius: Ayame.Units.cornerRadius
        color: control.colors.backgroundColor
        border.width: Ayame.Units.borderWidth
        border.color: Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, 0.3)
    }
}
