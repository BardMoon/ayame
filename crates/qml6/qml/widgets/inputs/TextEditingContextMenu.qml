pragma ComponentBehavior: Bound

import QtQuick
import Ayame 1.0 as Ayame

// Right-click menu for TextField/TextArea. QtQuick.Controls.Basic builds
// this from private QtQuick.Controls.impl Action helpers (UndoAction,
// CutAction, ...) that aren't available outside Qt's own style modules, so
// this wires the same operations directly against TextInput/TextEdit's own
// public API (undo()/redo()/cut()/copy()/paste()/selectAll(), canUndo/
// canRedo/selectedText/readOnly) instead.
Ayame.Menu {
    id: menu

    required property Item editor

    Ayame.MenuItem {
        text: qsTr("Undo")
        enabled: menu.editor.canUndo
        onTriggered: menu.editor.undo()
    }
    Ayame.MenuItem {
        text: qsTr("Redo")
        enabled: menu.editor.canRedo
        onTriggered: menu.editor.redo()
    }

    Ayame.MenuSeparator {}

    Ayame.MenuItem {
        text: qsTr("Cut")
        enabled: !menu.editor.readOnly && menu.editor.selectedText.length > 0
        onTriggered: menu.editor.cut()
    }
    Ayame.MenuItem {
        text: qsTr("Copy")
        enabled: menu.editor.selectedText.length > 0
        onTriggered: menu.editor.copy()
    }
    Ayame.MenuItem {
        text: qsTr("Paste")
        enabled: !menu.editor.readOnly && menu.editor.canPaste
        onTriggered: menu.editor.paste()
    }

    Ayame.MenuSeparator {}

    Ayame.MenuItem {
        text: qsTr("Select All")
        onTriggered: menu.editor.selectAll()
    }
}
