ecm_add_qml_module(AyameStyle URI "org.kde.ayame"
    GENERATE_PLUGIN_SOURCE
    DEPENDENCIES
        "QtQuick.Controls"
        "QtQuick.Window"
)

ecm_target_qml_sources(AyameStyle SOURCES
    ApplicationWindow.qml
    Button.qml
)

ecm_finalize_qml_module(AyameStyle)
