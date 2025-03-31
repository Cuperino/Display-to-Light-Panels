// Copyright (C) 2023-2025 Javier O. Cordero Pérez
// SPDX-License-Identifier: GPL-3.0-or-later

#include <QApplication>
#include <QQmlApplicationEngine>

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
using namespace Qt::Literals::StringLiterals;
#else
#include <screenmodel.h>
#endif

int main(int argc, char* argv[])
{
    QApplication app(argc, argv);
    QApplication::setOrganizationName(QString::fromLatin1("Cuperino"));
    QApplication::setOrganizationDomain(QString::fromLatin1("com.cuperino.lightpanel"));
    QApplication::setApplicationName(QString::fromLatin1("LightPanel"));

    QQmlApplicationEngine engine;

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    const QUrl url(u"qrc:/qt/qml/com/cuperino/lightpanel/main.qml"_s);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
#else
    qmlRegisterType<ScreenModel>("com.cuperino.lightpanel", 1, 0, "ScreenModel");
    const QUrl url(QLatin1String("qrc:/qt/qml/com/cuperino/lightpanel/main.qml"));
#endif
    engine.load(url);

    return app.exec();
}
