pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import QtQuick.Templates as T
import Ayame 1.0 as Ayame
import StyleKit 1.0 as StyleKit
import Qt.labs.StyleKit as LabsStyleKit

T.Dial {
    id: control

    // No dedicated StyleReader.ControlType for Dial -- falls back to
    // AyameStyle's generic `control` slot, same as PageIndicator/Tumbler/
    // RangeSlider below. `hovered` deliberately not fed in: the old ring
    // background never reacted to hover, only its border did (swapping to
    // full highlight, not `control`'s translucent hover-border tint) --
    // handled below with a direct control.hovered ternary instead, same
    // "opaque highlight passthrough" pattern as Slider.qml's handle.
    LabsStyleKit.StyleReader {
        id: styleReader
        controlType: LabsStyleKit.StyleReader.Control
        enabled: control.enabled
        focused: control.activeFocus
        palette: control.palette
    }

    hoverEnabled: true

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding, implicitBackgroundHeight + topInset + bottomInset)

    background: Item {
        id: backgroundItem
        implicitWidth: StyleKit.Units.gridUnit * 3.5
        implicitHeight: StyleKit.Units.gridUnit * 3.5

        // Noticeably thicker than TrackBar's bar thickness -- at bar
        // thickness this reads as basically invisible wrapped around a
        // ~gridUnit*3.5 circle instead of a strip. Still rounded to a
        // whole pixel for the same reason TrackBar.qml's thickness is
        // -- a fractional stroke width on a thin arc renders blurry.
        readonly property real ringThickness: Math.round(StyleKit.Units.smallSpacing * 3)

        // qqc2-style-breeze's Dial keeps the handle nearly filling the
        // whole circle, with just a thin groove right at its edge
        // (BreezeDial's grooveThickness is a small fraction of the
        // control size) -- half the ring's own thickness as margin
        // puts the groove astride the knob's edge instead of carving
        // out a big surrounding gap.
        Rectangle {
            anchors.fill: parent
            anchors.margins: parent.ringThickness / 2
            radius: width / 2
            color: styleReader.background.color
            border.width: styleReader.background.border.width
            border.color: control.hovered ? control.palette.highlight : styleReader.background.border.color
        }

        // A ProgressBar-like ring wrapped around the dial: a full-sweep
        // track (control.startAngle..endAngle, same look as
        // TrackBar/ProgressBar's plain bar) plus a highlighted arc
        // filled up to the current value, both round-capped.
        // PathAngleArc's 0deg is the 3-o'clock position and increases
        // clockwise, while Dial's angle/startAngle/endAngle are
        // measured from 12 o'clock -- hence the "-90" conversion below.
        Shape {
            id: progressRing
            anchors.fill: parent
            antialiasing: true
            preferredRendererType: Shape.CurveRenderer

            readonly property real _radius: (width - parent.ringThickness) / 2
            // A Shape stroke has no separate fill-inside-border concept
            // like Rectangle does, so the track (which needs a visibly
            // different border vs. fill color, same as TrackBar's plain
            // bar) is drawn as two concentric round-capped arcs: a
            // full-thickness borderColor band, then a narrower
            // backgroundColor band on top -- leaving a borderColor rim
            // showing all the way around, including at the rounded caps.
            readonly property real _trackFillStrokeWidth: Math.max(1, parent.ringThickness - StyleKit.Units.borderWidth * 2)

            ShapePath {
                // ShapePath isn't an Item -- `parent` here means the
                // Shape it's declared in (progressRing), not
                // progressRing's own visual parent, unlike every other
                // `parent.ringThickness` use in this file. Pre-existing
                // bug (undefined strokeWidth), caught by this migration's
                // headless verification since Dial had never actually
                // been instantiated in a headless run before.
                strokeWidth: backgroundItem.ringThickness
                strokeColor: styleReader.background.border.color
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: progressRing.width / 2
                    centerY: progressRing.height / 2
                    radiusX: progressRing._radius
                    radiusY: progressRing._radius
                    startAngle: control.startAngle - 90
                    sweepAngle: control.endAngle - control.startAngle
                }
            }

            ShapePath {
                strokeWidth: progressRing._trackFillStrokeWidth
                strokeColor: styleReader.background.color
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: progressRing.width / 2
                    centerY: progressRing.height / 2
                    radiusX: progressRing._radius
                    radiusY: progressRing._radius
                    startAngle: control.startAngle - 90
                    sweepAngle: control.endAngle - control.startAngle
                }
            }

            // Filled portion up to the current value -- flat
            // highlightColor, matching ProgressBar's own fill (which is
            // solid highlightColor for both border and background, so
            // no separate layering is needed here).
            ShapePath {
                strokeWidth: backgroundItem.ringThickness
                strokeColor: control.palette.highlight
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: progressRing.width / 2
                    centerY: progressRing.height / 2
                    radiusX: progressRing._radius
                    radiusY: progressRing._radius
                    startAngle: control.startAngle - 90
                    sweepAngle: control.angle - control.startAngle
                }
            }
        }
    }

    handle: Rectangle {
        id: handleItem
        x: control.background.x + control.background.width / 2 - width / 2
        y: control.background.y + control.background.height / 2 - height / 2
        width: 10
        height: 10
        radius: 5
        color: control.palette.highlight
        transform: [
            Translate {
                y: -control.background.height / 2 + 8
            },
            Rotation {
                angle: control.angle
                origin.x: handleItem.width / 2
                origin.y: handleItem.height / 2
            }
        ]
    }
}
