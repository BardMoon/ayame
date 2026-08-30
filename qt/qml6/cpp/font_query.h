#pragma once

extern "C" {

char* cettila_available_font_families_joined();
char* cettila_current_font_family();
double cettila_current_font_point_size();
void cettila_apply_ui_font(const char* family, double pointSize);
void cettila_free_font_query_string(char* s);

} // extern "C"
