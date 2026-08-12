pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import la.cettila.Ayame 1.0

QQC2.ScrollIndicator {
    id: control

    property int colorSet: Theme.view
    readonly property var colors: Theme.paletteFor(control.colorSet)

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
