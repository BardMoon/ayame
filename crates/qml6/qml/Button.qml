import QtQuick
import QtQuick.Templates as T

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                             implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                              implicitContentHeight + topPadding + bottomPadding)

    padding: 6
    spacing: 6

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.palette.buttonText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 32
        radius: 4
        color: control.down ? control.palette.dark : control.palette.button
        border.width: 1
        border.color: control.palette.mid
    }
}
