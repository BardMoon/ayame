#include "theme_palette.h"

#include <QtGui/QColor>
#include <QtGui/QGuiApplication>
#include <QtGui/QPalette>

namespace {

QColor fromRgb(uint32_t rgb)
{
    return QColor::fromRgb(rgb);
}

bool g_capturedSystemPalette = false;
QPalette g_systemPalette;

} // namespace

extern "C" {

void cettila_apply_theme_palette(
    int mode,
    uint32_t window,
    uint32_t windowText,
    uint32_t base,
    uint32_t alternateBase,
    uint32_t text,
    uint32_t button,
    uint32_t buttonText,
    uint32_t highlight,
    uint32_t highlightedText,
    uint32_t tooltipBase,
    uint32_t tooltipText,
    uint32_t light)
{
    if (!g_capturedSystemPalette) {
        g_systemPalette = QGuiApplication::palette();
        g_capturedSystemPalette = true;
    }

    if (mode != 1) {
        QGuiApplication::setPalette(g_systemPalette);
        return;
    }

    QPalette pal;
    pal.setColor(QPalette::Window, fromRgb(window));
    pal.setColor(QPalette::WindowText, fromRgb(windowText));
    pal.setColor(QPalette::Base, fromRgb(base));
    pal.setColor(QPalette::AlternateBase, fromRgb(alternateBase));
    pal.setColor(QPalette::Text, fromRgb(text));
    pal.setColor(QPalette::Button, fromRgb(button));
    pal.setColor(QPalette::ButtonText, fromRgb(buttonText));
    pal.setColor(QPalette::Highlight, fromRgb(highlight));
    pal.setColor(QPalette::HighlightedText, fromRgb(highlightedText));
    pal.setColor(QPalette::ToolTipBase, fromRgb(tooltipBase));
    pal.setColor(QPalette::ToolTipText, fromRgb(tooltipText));
    pal.setColor(QPalette::Light, fromRgb(light));
    QGuiApplication::setPalette(pal);
}

} // extern "C"
