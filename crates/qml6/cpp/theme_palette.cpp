#include "theme_palette.h"

#include <QtGui/QColor>
#include <QtGui/QGuiApplication>
#include <QtGui/QPalette>

namespace {

QPalette lightPalette()
{
    QPalette pal;
    pal.setColor(QPalette::Window, QColor(0xef, 0xf0, 0xf1));
    pal.setColor(QPalette::WindowText, QColor(0x23, 0x26, 0x29));
    pal.setColor(QPalette::Base, QColor(0xfc, 0xfc, 0xfc));
    pal.setColor(QPalette::AlternateBase, QColor(0xef, 0xf0, 0xf1));
    pal.setColor(QPalette::Text, QColor(0x23, 0x26, 0x29));
    pal.setColor(QPalette::Button, QColor(0xef, 0xf0, 0xf1));
    pal.setColor(QPalette::ButtonText, QColor(0x23, 0x26, 0x29));
    pal.setColor(QPalette::Highlight, QColor(0x3d, 0xae, 0xe9));
    pal.setColor(QPalette::HighlightedText, QColor(0xfc, 0xfc, 0xfc));
    pal.setColor(QPalette::ToolTipBase, QColor(0xf7, 0xf7, 0xf7));
    pal.setColor(QPalette::ToolTipText, QColor(0x23, 0x26, 0x29));
    pal.setColor(QPalette::Light, QColor(0xff, 0xff, 0xff));
    return pal;
}

QPalette darkPalette()
{
    QPalette pal;
    pal.setColor(QPalette::Window, QColor(0x31, 0x36, 0x3b));
    pal.setColor(QPalette::WindowText, QColor(0xef, 0xf0, 0xf1));
    pal.setColor(QPalette::Base, QColor(0x23, 0x26, 0x29));
    pal.setColor(QPalette::AlternateBase, QColor(0x31, 0x36, 0x3b));
    pal.setColor(QPalette::Text, QColor(0xef, 0xf0, 0xf1));
    pal.setColor(QPalette::Button, QColor(0x31, 0x36, 0x3b));
    pal.setColor(QPalette::ButtonText, QColor(0xef, 0xf0, 0xf1));
    pal.setColor(QPalette::Highlight, QColor(0x3d, 0xae, 0xe9));
    pal.setColor(QPalette::HighlightedText, QColor(0xef, 0xf0, 0xf1));
    pal.setColor(QPalette::ToolTipBase, QColor(0x31, 0x36, 0x3b));
    pal.setColor(QPalette::ToolTipText, QColor(0xef, 0xf0, 0xf1));
    pal.setColor(QPalette::Light, QColor(0x4d, 0x4d, 0x4d));
    return pal;
}

bool g_capturedSystemPalette = false;
QPalette g_systemPalette;

} // namespace

extern "C" {

void cettila_apply_theme_mode(int mode)
{
    if (!g_capturedSystemPalette) {
        g_systemPalette = QGuiApplication::palette();
        g_capturedSystemPalette = true;
    }

    switch (mode) {
    case 1:
        QGuiApplication::setPalette(lightPalette());
        break;
    case 2:
        QGuiApplication::setPalette(darkPalette());
        break;
    default:
        QGuiApplication::setPalette(g_systemPalette);
        break;
    }
}

} // extern "C"
