#include "displaywindow.h"

#include <QApplication>
#include <QLocale>
#include <QTranslator>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    QPalette pal = a.palette();
    pal.setColor(QPalette::Window, Qt::white);
    pal.setColor(QPalette::WindowText, Qt::darkGray);
    pal.setColor(QPalette::ButtonText, Qt::darkGray);
    pal.setColor(QPalette::BrightText, Qt::lightGray);
    a.setPalette(pal);

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "displaytolightpanel_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            a.installTranslator(&translator);
            break;
        }
    }

    DisplayWindow w;
    w.show();
    return a.exec();
}
