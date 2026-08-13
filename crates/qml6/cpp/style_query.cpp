#include "style_query.h"

#include <QtCore/QDir>
#include <QtCore/QFile>
#include <QtCore/QLibraryInfo>
#include <QtCore/QSet>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtQuickControls2/QQuickStyle>
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

QStringList importPathRoots()
{
    QStringList roots;
    roots << QLibraryInfo::path(QLibraryInfo::QmlImportsPath);
    for (const char* var : {"QML2_IMPORT_PATH", "QML_IMPORT_PATH"}) {
        const QByteArray value = qgetenv(var);
        if (!value.isEmpty()) {
            roots += QString::fromLocal8Bit(value).split(QDir::listSeparator(), Qt::SkipEmptyParts);
        }
    }
    roots << QStringLiteral(":/qt/qml");
    roots << QStringLiteral(":/qt-project.org/imports");
    return roots;
}

bool looksLikeStyleQmldir(const QString& path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;
    const QString content = QString::fromUtf8(file.readAll());
    return content.contains(QLatin1String("ApplicationWindow"))
        || content.contains(QLatin1String("Button"))
        || content.contains(QLatin1String("la.cettila.Ayame"))
        || content.contains(QLatin1String("QtQuick.Controls"));
}

void collectStylesUnder(const QString& root, const QString& relativeDir, const QString& namePrefix, QSet<QString>& out)
{
    QDir base(root + QLatin1Char('/') + relativeDir);
    if (!base.exists())
        return;

    for (const QString& entry : base.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        const QString qmldirPath = base.filePath(entry + QLatin1String("/qmldir"));
        if (!QFile::exists(qmldirPath) || !looksLikeStyleQmldir(qmldirPath))
            continue;
        out.insert(namePrefix.isEmpty() ? entry : namePrefix + QLatin1Char('.') + entry);
    }
}

} // namespace

extern "C" {

char* cettila_available_styles_joined()
{
    QSet<QString> styles;
    for (const QString& root : importPathRoots()) {
        collectStylesUnder(root, QLatin1String("QtQuick/Controls"), QString(), styles);
        collectStylesUnder(root, QLatin1String("org/kde"), QLatin1String("org.kde"), styles);
        collectStylesUnder(root, QLatin1String("la/cettila"), QLatin1String("la.cettila"), styles);
    }

    // Always check for embedded/registered Ayame modules as fallbacks
    if (QFile::exists(QStringLiteral(":/qt/qml/la/cettila/Ayame/qmldir")) ||
        QFile::exists(QStringLiteral(":/qt-project.org/imports/la/cettila/Ayame/qmldir"))) {
        styles.insert(QStringLiteral("la.cettila.Ayame"));
    }
    if (QFile::exists(QStringLiteral(":/qt/qml/QtQuick/Controls/Ayame/qmldir")) ||
        QFile::exists(QStringLiteral(":/qt-project.org/imports/QtQuick/Controls/Ayame/qmldir"))) {
        styles.insert(QStringLiteral("Ayame"));
    }

    QStringList sorted = styles.values();
    sorted.sort(Qt::CaseInsensitive);
    return dupQString(sorted.join(QLatin1Char('\n')));
}

char* cettila_current_style_name()
{
    return dupQString(QQuickStyle::name());
}

void cettila_free_style_query_string(char* s)
{
    delete[] s;
}

} // extern "C"
