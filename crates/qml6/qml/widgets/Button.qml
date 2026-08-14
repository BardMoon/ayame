pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import QtQuick.Templates as T
import Ayame 1.0 as Ayame

T.Button {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    hoverEnabled: true

    implicitHeight: Ayame.Units.gridUnit * 1.6
    implicitWidth: contentItem.implicitWidth + Ayame.Units.largeSpacing * 2

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: Ayame.Units.cornerRadius
            color: control.pressed ? control.colors.highlightColor : (control.hovered ? control.colors.hoverColor : control.colors.backgroundColor)
            border.width: Ayame.Units.borderWidth
            border.color: control.activeFocus ? control.colors.highlightColor : Qt.rgba(control.colors.textColor.r, control.colors.textColor.g, control.colors.textColor.b, control.hovered ? 0.4 : 0.3)
        }

        // Spinning highlight ring, replacing the old static
        // activeFocus-turns-the-border-highlightColor treatment: a ring
        // shape (outer rect minus an inset inner rect, punched out via
        // odd-even fill) filled with a ConicalGradient whose angle is
        // animated in an infinite loop, so a bright arc appears to chase
        // around the border while the control actually has keyboard focus.
        Shape {
            id: activeRing
            anchors.fill: parent
            visible: (control.highlighted || control.pressed) && Ayame.Units.animationsEnabled
            antialiasing: true
            preferredRendererType: Shape.CurveRenderer

            readonly property real ringThickness: Ayame.Units.borderWidth

            ShapePath {
                fillRule: ShapePath.OddEvenFill
                strokeColor: "transparent"
                fillColor: "transparent"
                fillGradient: ConicalGradient {
                    id: ringGradient
                    centerX: activeRing.width / 2
                    centerY: activeRing.height / 2

                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.6; color: "transparent" }
                    GradientStop { position: 0.85; color: control.colors.highlightColor }
                    GradientStop { position: 1.0; color: "transparent" }
                }

                PathRectangle {
                    x: 0
                    y: 0
                    width: activeRing.width
                    height: activeRing.height
                    radius: Ayame.Units.cornerRadius
                }
                PathRectangle {
                    x: activeRing.ringThickness
                    y: activeRing.ringThickness
                    width: activeRing.width - activeRing.ringThickness * 2
                    height: activeRing.height - activeRing.ringThickness * 2
                    radius: Math.max(0, Ayame.Units.cornerRadius - activeRing.ringThickness)
                }
            }

            NumberAnimation {
                target: ringGradient
                property: "angle"
                running: (control.highlighted || control.pressed) && Ayame.Units.animationsEnabled
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: Ayame.Units.veryLongDuration * 4
            }
        }
    }

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: control.text
        font: control.font
        color: control.pressed ? control.colors.highlightedTextColor : control.colors.textColor

        Behavior on color {
            ColorAnimation { duration: Ayame.Units.shortDuration; easing.type: Easing.OutCubic }
        }
    }
}
