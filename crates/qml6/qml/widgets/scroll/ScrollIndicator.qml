pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Ayame 1.0 as Ayame

T.ScrollIndicator {
    id: control

    property int colorSet: Ayame.Theme.view
    readonly property var colors: Ayame.Theme.paletteFor(control.colorSet)

    padding: 2

    contentItem: Rectangle {
        implicitWidth: 4
        implicitHeight: 4
        radius: 2
        color: control.colors.highlightColor
        opacity: control.active ? 0.6 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }
}
