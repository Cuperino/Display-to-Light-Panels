#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setOrganizationName(QString::fromUtf8("Cuperino"));
    QGuiApplication::setOrganizationDomain(QString::fromUtf8("com.cuperino.lightpanel"));
    QGuiApplication::setApplicationName(QString::fromUtf8("LightPanel"));

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/DisplayToLightPanel/Main.qml"_qs);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
