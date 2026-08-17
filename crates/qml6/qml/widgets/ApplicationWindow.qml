pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.ApplicationWindow {
    id: window

    property int colorSet: StyleKit.Theme.window
    readonly property var colors: StyleKit.Theme.paletteFor(window.colorSet)

    color: window.colors.backgroundColor

    // Root of the QQC2 item tree, so every StyleReader below (see
    // Button.qml's pilot conversion, task file Phase 1) resolves against
    // this one Style instance via Qt.labs.StyleKit's attached-property
    // lookup.
    LabsStyleKit.StyleKit.style: Ayame.AyameStyle {}
}
