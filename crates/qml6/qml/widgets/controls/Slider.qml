pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.Slider {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true
    implicitWidth: control.horizontal ? Ayame.Units.gridUnit * 8 : Ayame.Units.gridUnit * 1.4
    implicitHeight: control.horizontal ? Ayame.Units.gridUnit * 1.4 : Ayame.Units.gridUnit * 8

    readonly property real _handleSize: Ayame.Units.iconSizes.small

    background: Ayame.TrackBar {
        id: track
        x: control.leftPadding + (control.horizontal ? 0 : Math.round((control.availableWidth - width) / 2))
        y: control.topPadding + (control.horizontal ? Math.round((control.availableHeight - height) / 2) : 0)
        width: control.horizontal ? control.availableWidth : track.thickness
        height: control.horizontal ? track.thickness : control.availableHeight
        trackColor: control.colors.backgroundColor
        trackBorderColor: control.colors.borderColor

        // Same size as the track (not inset). Matches ProgressBar's
        // fill so both read the same way.
        Rectangle {
            y: control.horizontal ? 0 : control.visualPosition * parent.height
            width: control.horizontal ? control.position * parent.width : parent.width
            height: control.horizontal ? parent.height : control.position * parent.height
            radius: parent.radius
            color: control.colors.highlightColor
            border.width: Ayame.Units.borderWidth
            border.color: control.colors.highlightColor
        }
    }

    handle: Item {
        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height))
        implicitWidth: control._handleSize
        implicitHeight: control._handleSize

        // colors.hoverColor/pressedColor are translucent (designed as a
        // wash over some other opaque background, e.g. Button.qml's
        // fill) -- using them directly here made the handle look like
        // it was turning see-through against the track underneath it.
        // highlightColor itself is opaque, so it's fine to use directly
        // for the pressed fill.
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: control.pressed ? control.colors.highlightColor : control.colors.backgroundColor
            border.width: Ayame.Units.borderWidth
            border.color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverBorderColor : control.colors.borderColor)
        }

        // Same activeFocus cue as widgets/Button.qml -- see
        // HighlightRing.qml -- cornerRadius pinned to half the handle
        // size so it stays circular.
        Ayame.HighlightRing {
            anchors.fill: parent
            cornerRadius: parent.width / 2
            active: control.activeFocus
            ringColor: control.colors.highlightColor
        }
    }
}
