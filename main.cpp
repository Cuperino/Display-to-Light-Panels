// Copyright (C) 2023 Javier O. Cordero Pérez
// SPDX-License-Identifier: GPL-3.0-or-later

#include <QApplication>
#include <QQmlApplicationEngine>

int main(int argc, char* argv[])
{
    QApplication app(argc, argv);
    QApplication::setOrganizationName(QString::fromUtf8("Cuperino"));
    QApplication::setOrganizationDomain(QString::fromUtf8("com.cuperino.lightpanel"));
    QApplication::setApplicationName(QString::fromUtf8("LightPanel"));

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/qt/qml/DisplayToLightPanel/Main.qml"_qs);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
