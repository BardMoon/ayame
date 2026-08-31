pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.ProgressBar {
    id: control

    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.ProgressBar
        enabled: control.enabled
        palette: control.palette
    }

    // Pinned to the shared track thickness (not derived via the usual
    // implicitContentHeight + padding formula) -- same reasoning as
    // Slider: the fill below is the same size as the track, so the
    // control itself should be too.
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: track.thickness

    background: Ayame.TrackBar {
        id: track
        implicitWidth: StyleKit.Units.gridUnit * 8
        trackColor: styleReader.background.color
        trackBorderColor: styleReader.background.border.color
    }

    contentItem: Item {
        implicitWidth: StyleKit.Units.gridUnit * 8
        implicitHeight: track.thickness
        clip: true

        // Same size as the track (not inset).
        Rectangle {
            visible: !control.indeterminate
            width: control.position * parent.width
            height: parent.height
            radius: track.radius
            color: control.palette.highlight
            border.width: styleReader.background.border.width
            border.color: control.palette.highlight
        }

        // control.position isn't meaningful while indeterminate -- a
        // repeating stripe pattern scrolling left-to-right forever
        // instead. stripesRow is laid out one repeat unit (two stripes)
        // wider than it needs to be and cycled by exactly one repeat
        // unit, so the loop point is seamless.
        // Inset by the border width, unlike the determinate fill above --
        // the stripes are a separate repeating pattern next to the
        // track's own border rather than a bordered shape coincident
        // with it, so left uninset they'd visibly draw over it.
        Item {
            id: indeterminateLayer
            x: StyleKit.Units.borderWidth
            y: StyleKit.Units.borderWidth
            width: parent.width - StyleKit.Units.borderWidth * 2
            height: parent.height - StyleKit.Units.borderWidth * 2
            visible: control.indeterminate

            readonly property real stripeWidth: StyleKit.Units.smallSpacing * 6
            readonly property real gapWidth: StyleKit.Units.smallSpacing * 4
            readonly property real repeatWidth: stripeWidth + gapWidth

            Row {
                id: stripesRow
                height: parent.height

                Repeater {
                    model: Math.ceil(indeterminateLayer.width / indeterminateLayer.gapWidth) + 4

                    Rectangle {
                        required property int index

                        width: index % 2 === 0 ? indeterminateLayer.stripeWidth : indeterminateLayer.gapWidth
                        height: parent.height
                        radius: track.radius
                        color: index % 2 === 0 ? styleReader.background.border.color : "transparent"
                    }
                }

                NumberAnimation on x {
                    running: control.indeterminate && StyleKit.Units.animationsEnabled
                    loops: Animation.Infinite
                    from: -indeterminateLayer.repeatWidth
                    to: 0
                    duration: StyleKit.Units.veryLongDuration * 2
                }
            }
        }
    }
}
