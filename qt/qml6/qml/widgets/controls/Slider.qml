pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.Slider {
    id: control

    // No dedicated StyleReader.ControlType for Slider -- falls back to
    // the generic `control` slot. Track (rest-only, not interactive) and
    // handle (reacts to hover/pressed) get separate StyleReaders since
    // they need different state.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Control
        enabled: control.enabled
        palette: control.palette
    }

    LabsStyleKit.StyleReader {
        id: handleStyleReader
        controlType: LabsStyleKit.StyleReader.Control
        enabled: control.enabled
        hovered: control.hovered
        pressed: control.pressed
        palette: control.palette
    }

    hoverEnabled: true
    implicitWidth: control.horizontal ? StyleKit.Units.gridUnit * 8 : StyleKit.Units.gridUnit * 1.4
    implicitHeight: control.horizontal ? StyleKit.Units.gridUnit * 1.4 : StyleKit.Units.gridUnit * 8

    readonly property real _handleSize: StyleKit.Units.iconSizes.small

    background: Ayame.TrackBar {
        id: track
        x: control.leftPadding + (control.horizontal ? 0 : Math.round((control.availableWidth - width) / 2))
        y: control.topPadding + (control.horizontal ? Math.round((control.availableHeight - height) / 2) : 0)
        width: control.horizontal ? control.availableWidth : track.thickness
        height: control.horizontal ? track.thickness : control.availableHeight
        trackColor: styleReader.background.color
        trackBorderColor: styleReader.background.border.color

        // Same size as the track (not inset). Matches ProgressBar's
        // fill so both read the same way.
        Rectangle {
            y: control.horizontal ? 0 : control.visualPosition * parent.height
            width: control.horizontal ? control.position * parent.width : parent.width
            height: control.horizontal ? parent.height : control.position * parent.height
            radius: parent.radius
            color: control.palette.highlight
            border.width: styleReader.background.border.width
            border.color: control.palette.highlight
        }
    }

    handle: Item {
        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height))
        implicitWidth: control._handleSize
        implicitHeight: control._handleSize

        // `control`'s translucent pressed/hovered tints are designed as
        // a wash over some other opaque background (e.g. Button.qml's
        // fill) -- using them directly here made the handle look like it
        // was turning see-through against the track underneath it, so
        // pressed still forces the opaque palette.highlight fill/border
        // directly instead of going through handleStyleReader for that
        // one state.
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: control.pressed ? control.palette.highlight : handleStyleReader.background.color
            border.width: handleStyleReader.background.border.width
            border.color: control.pressed ? control.palette.highlight : handleStyleReader.background.border.color
        }

        // Same activeFocus cue as widgets/Button.qml -- see
        // HighlightRing.qml -- cornerRadius pinned to half the handle
        // size so it stays circular.
        Ayame.HighlightRing {
            anchors.fill: parent
            cornerRadius: parent.width / 2
            active: control.activeFocus
            ringColor: control.palette.highlight
        }
    }
}
