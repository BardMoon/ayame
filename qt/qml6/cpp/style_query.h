#pragma once

extern "C" {

char* cettila_available_styles_joined();
char* cettila_current_style_name();
void cettila_free_style_query_string(char* s);

} // extern "C"
