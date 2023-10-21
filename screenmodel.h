#ifndef SCREENMODEL_H
#define SCREENMODEL_H

#include "internalmessagebroker.hpp"

#include <QAbstractListModel>
#include <QQmlEngine>
#include <QSettings>

struct ColorProperties {
    int hue;
    int lightness;
    int saturation;
};

class ScreenModel : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(const QString &screenName READ getCurrentScreen WRITE setCurrentScreen NOTIFY currentScreenChanged)
    Q_PROPERTY(int hue READ getScreenHue WRITE setScreenHue NOTIFY screenHueChanged)
    Q_PROPERTY(int lightness READ getScreenLightness WRITE setScreenLightness NOTIFY screenLightnessChanged)
    Q_PROPERTY(int saturation READ getScreenSaturation WRITE setScreenSaturation NOTIFY screenSaturationChanged)
public:
    explicit ScreenModel(QObject* parent = nullptr);

    QString getCurrentScreen();
    int getScreenHue();
    int getScreenLightness();
    int getScreenSaturation();

    void setCurrentScreen(const QString &screenName);
    void setScreenHue(int hue, bool spread=true);
    void setScreenLightness(int lightness, bool spread=true);
    void setScreenSaturation(int saturation, bool spread=true);

signals:
    void currentScreenChanged();

    void spreadHueChange(int hue, bool baseCase);
    void spreadLightnessChange(int lightness, bool baseCase);
    void spreadSaturationChange(int saturation, bool baseCase);

    void screenHueChanged();
    void screenLightnessChanged();
    void screenSaturationChanged();

private:
    void initializeScreenMap();
    std::shared_ptr<InternalMessageBroker> m_mb;
    QString m_currentScreen;
    QMap<const QString, ColorProperties> m_screens;
};

#endif // SCREENMODEL_H
