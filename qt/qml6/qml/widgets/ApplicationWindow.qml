pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import Qt.labs.StyleKit as LabsStyleKit

T.ApplicationWindow {
    id: window

    // Root of the QQC2 item tree, so every StyleReader below (see
    // Button.qml's pilot conversion, task file Phase 1) resolves against
    // this one Style instance via Qt.labs.StyleKit's attached-property
    // lookup. Also used by this window's own StyleReader below.
    LabsStyleKit.StyleKit.style: Ayame.AyameStyle {}

    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.ApplicationWindow
        palette: window.palette
    }

    color: styleReader.background.color
}
