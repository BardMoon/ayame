#include "font_query.h"

#include <QtGui/QFontDatabase>
#include <QtGui/QGuiApplication>
#include <cstring>

namespace {

char* dupQString(const QString& s)
{
    QByteArray utf8 = s.toUtf8();
    char* buf = new char[static_cast<size_t>(utf8.size()) + 1];
    std::memcpy(buf, utf8.constData(), static_cast<size_t>(utf8.size()));
    buf[utf8.size()] = '\0';
    return buf;
}

} // namespace

extern "C" {

char* cettila_available_font_families_joined()
{
    QStringList families = QFontDatabase::families();
    families.sort(Qt::CaseInsensitive);
    return dupQString(families.join(QLatin1Char('\n')));
}

char* cettila_current_font_family()
{
    return dupQString(QGuiApplication::font().family());
}

double cettila_current_font_point_size()
{
    return QGuiApplication::font().pointSizeF();
}

void cettila_apply_ui_font(const char* family, double pointSize)
{
    QFont font = QGuiApplication::font();
    if (family != nullptr && family[0] != '\0') {
        font.setFamily(QString::fromUtf8(family));
    }
    if (pointSize > 0.0) {
        font.setPointSizeF(pointSize);
    }
    QGuiApplication::setFont(font);
}

void cettila_free_font_query_string(char* s)
{
    delete[] s;
}

} // extern "C"
