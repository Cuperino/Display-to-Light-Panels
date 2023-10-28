#include "screenmodel.h"
#include "internalmessagebroker.hpp"

#include <QGuiApplication>
#include <QScreen>

ScreenModel::ScreenModel(QObject* parent)
    : QObject { parent }
{
    connect(qGuiApp, &QGuiApplication::screenAdded, this, &ScreenModel::initializeScreenMap);

    m_mb = InternalMessageBroker::instance();
    connect(this, &ScreenModel::spreadHueChange, m_mb.get(), &InternalMessageBroker::hueChanged);
    connect(m_mb.get(), &InternalMessageBroker::hueChanged, this, &ScreenModel::setScreenHue);
    connect(this, &ScreenModel::spreadLightnessChange, m_mb.get(), &InternalMessageBroker::lightnessChanged);
    connect(m_mb.get(), &InternalMessageBroker::lightnessChanged, this, &ScreenModel::setScreenLightness);
    connect(this, &ScreenModel::spreadSaturationChange, m_mb.get(), &InternalMessageBroker::saturationChanged);
    connect(m_mb.get(), &InternalMessageBroker::saturationChanged, this, &ScreenModel::setScreenSaturation);
}

QString ScreenModel::getCurrentScreen()
{
    return m_currentScreen;
}

void ScreenModel::initializeScreenMap()
{
    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());
    for (QScreen* screen : QGuiApplication::screens()) {
        QString screenName = screen->name();
        const int hue = settings.value(screenName + "s/hue", 180).toInt();
        const int lightness = settings.value(screenName + "s/lightness", 250).toInt();
        const int saturation = settings.value(screenName + "s/saturation", 255).toInt();
        ColorProperties color {
            hue,
            lightness,
            saturation
        };
        m_screens[screenName] = color;
        emit spreadHueChange(hue, false, screenName);
        emit spreadLightnessChange(lightness, false, screenName);
        emit spreadSaturationChange(saturation, false, screenName);
    }
}

int ScreenModel::getScreenHue()
{
    return m_screens[m_currentScreen].hue;
}

int ScreenModel::getScreenLightness()
{
    return m_screens[m_currentScreen].lightness;
}

int ScreenModel::getScreenSaturation()
{
    return m_screens[m_currentScreen].saturation;
}

void ScreenModel::setCurrentScreen(const QString &screenName)
{
    m_currentScreen = screenName;
    initializeScreenMap();
}

void ScreenModel::setScreenHue(const int hue, const bool spread, const QString &screenName)
{
    if (spread) {
        m_screens[m_currentScreen].hue = hue;
        emit spreadHueChange(hue, false, m_currentScreen);
    }
    else if (m_currentScreen == screenName) {
        m_screens[m_currentScreen].hue = hue;
        emit screenHueChanged();
    }
}

void ScreenModel::setScreenLightness(const int lightness, const bool spread, const QString &screenName)
{
    if (spread) {
        m_screens[m_currentScreen].lightness = lightness;
        emit spreadLightnessChange(lightness, false, m_currentScreen);
    }
    else if (m_currentScreen == screenName) {
        m_screens[m_currentScreen].lightness = lightness;
        emit screenLightnessChanged();
    }
}

void ScreenModel::setScreenSaturation(const int saturation, const bool spread, const QString &screenName)
{
    if (spread) {
        m_screens[m_currentScreen].saturation = saturation;
        emit spreadSaturationChange(saturation, false, m_currentScreen);
    }
    else if (m_currentScreen == screenName) {
        m_screens[m_currentScreen].saturation = saturation;
        emit screenSaturationChanged();
    }
}

void ScreenModel::clear(const int length)
{
    QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());
    for (int i=-1; i<length; i++) {
        auto key = QStringLiteral("n%1").arg(i);
        settings.remove(key);
    }
}
