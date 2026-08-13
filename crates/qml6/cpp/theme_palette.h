#pragma once

#include <cstdint>

extern "C" {

// `window`..`light` are packed 0xRRGGBB (QRgb) values for the twelve
// QPalette roles Ayame overrides; the color data itself now lives in the
// `ayame-colors` Rust crate (see `ayame::apply_theme`), not here. `mode` is
// 0 = system (restore the palette captured before Ayame ever touched it),
// 1 = light, 2 = dark -- same encoding as the old `cettila_apply_theme_mode`.
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
    uint32_t light);

} // extern "C"
