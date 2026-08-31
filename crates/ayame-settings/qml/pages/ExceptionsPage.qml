import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

QQC2.Page {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        QQC2.Label {
            text: "Window Specific Overrides / Exceptions"
            font.pixelSize: 18
            font.bold: true
        }

        QQC2.Label {
            text: "Not yet implemented -- these settings target the kdecoration6 plugin, which does not exist yet."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            opacity: 0.7
        }

        Item { Layout.fillHeight: true }
    }
}
