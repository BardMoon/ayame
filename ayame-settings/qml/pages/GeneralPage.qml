import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.ayame.settings

QQC2.Page {
    id: root

    required property AyameSettingsObject settings

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        QQC2.Label {
            text: "General Settings"
            font.pixelSize: 18
            font.bold: true
        }

        QQC2.CheckBox {
            text: "Draw Widget Borders"
            checked: root.settings.draw_widget_borders
            onCheckedChanged: root.settings.draw_widget_borders = checked
        }

        QQC2.CheckBox {
            id: animCheck
            text: "Enable UI Animations"
            checked: root.settings.animations_enabled
            onCheckedChanged: root.settings.animations_enabled = checked
        }

        RowLayout {
            enabled: animCheck.checked
            spacing: 8

            QQC2.Label { text: "Animation Duration (ms):" }

            QQC2.SpinBox {
                from: 50
                to: 1000
                stepSize: 25
                value: root.settings.animation_duration_ms
                onValueChanged: root.settings.animation_duration_ms = value
            }
        }

        Item { Layout.fillHeight: true }
    }
}
