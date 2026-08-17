pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.Tumbler {
    id: control

    // No dedicated StyleReader.ControlType for Tumbler -- falls back to
    // the generic `control` slot, same as Dial/PageIndicator/RangeSlider.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Control
        enabled: control.enabled
        palette: control.palette
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    readonly property real __delegateHeight: availableHeight / visibleItemCount

    // Without this, T.Tumbler (headless) has no actual scrolling view to
    // render its columns into -- same missing-piece shape as ComboBox's
    // missing popup/delegate. Matches QtQuick.Controls.Basic's own
    // Tumbler.qml (TumblerView + Path wiring).
    // contentItem: TumblerView {
    //     implicitWidth: StyleKit.Units.gridUnit * 3
    //     implicitHeight: StyleKit.Units.gridUnit * 1.6 * control.visibleItemCount
    //     model: control.model
    //     delegate: control.delegate
    //     path: Path {
    //         startX: control.contentItem.width / 2
    //         startY: -control.__delegateHeight / 2

    //         PathLine {
    //             x: control.contentItem.width / 2
    //             y: (control.visibleItemCount + 1) * control.__delegateHeight - control.__delegateHeight / 2
    //         }
    //     }
    // }

    background: Rectangle {
        radius: StyleKit.Units.cornerRadius
        color: styleReader.background.color
        border.width: styleReader.background.border.width
        border.color: styleReader.background.border.color
    }

    delegate: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: modelData
        font: control.font
        color: styleReader.text.color
        opacity: 0.4 + (1.0 - Math.abs(Tumbler.displacement) / (control.visibleItemCount / 2)) * 0.6
    }
}
