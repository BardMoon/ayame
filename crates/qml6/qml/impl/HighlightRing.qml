import QtQuick
import QtQuick.Shapes
import Ayame 1.0 as Ayame

// A ring shape (outer rect minus an inset inner rect, punched out via
// odd-even fill) filled with a ConicalGradient whose angle is animated in
// an infinite loop, so a bright arc appears to chase around a control's
// border while `animating` is true. Extracted from Button.qml's
// activeFocus treatment so any focusable/highlightable control can reuse
// it -- anchor it to `parent.fill` and drive `animating` from whatever
// condition means "draw attention to this control" for that control
// (pressed/highlighted/activeFocus, ANDed with `Ayame.Units.animationsEnabled`
// since the caller is responsible for that check, same as Button.qml was).
Shape {
    id: root

    property bool animating: false
    property color ringColor: "transparent"
    property real cornerRadius: Ayame.Units.cornerRadius
    property real ringThickness: Ayame.Units.borderWidth
    property int duration: Ayame.Units.veryLongDuration * 4

    visible: root.animating
    antialiasing: true
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillRule: ShapePath.OddEvenFill
        strokeColor: "transparent"
        fillColor: "transparent"
        fillGradient: ConicalGradient {
            id: ringGradient
            centerX: root.width / 2
            centerY: root.height / 2

            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.6; color: "transparent" }
            GradientStop { position: 0.85; color: root.ringColor }
            GradientStop { position: 1.0; color: "transparent" }
        }

        PathRectangle {
            x: 0
            y: 0
            width: root.width
            height: root.height
            radius: root.cornerRadius
        }
        PathRectangle {
            x: root.ringThickness
            y: root.ringThickness
            width: root.width - root.ringThickness * 2
            height: root.height - root.ringThickness * 2
            radius: Math.max(0, root.cornerRadius - root.ringThickness)
        }
    }

    NumberAnimation {
        target: ringGradient
        property: "angle"
        running: root.animating
        loops: Animation.Infinite
        from: 0
        to: 360
        duration: root.duration
    }
}
