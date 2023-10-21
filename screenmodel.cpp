#include "screenmodel.h"
#include "internalmessagebroker.hpp"

#include <QGuiApplication>
#include <QScreen>

ScreenModel::ScreenModel(QObject* parent)
    : QObject { parent }
{
    initializeScreenMap();

    connect(qGuiApp, &QGuiApplication::screenAdded, this, &ScreenModel::initializeScreenMap);
    connect(qGuiApp, &QGuiApplication::screenRemoved, this, &ScreenModel::initializeScreenMap);

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
        emit spreadLightnessChange(hue, false);
        emit spreadLightnessChange(lightness, false);
        emit spreadLightnessChange(saturation, false);
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
}

void ScreenModel::setScreenHue(int hue, bool spread)
{
    m_screens[m_currentScreen].hue = hue;
    if (spread)
        emit spreadHueChange(hue, false);
    else
        emit screenHueChanged();
}

void ScreenModel::setScreenLightness(int lightness, bool spread)
{
    m_screens[m_currentScreen].lightness = lightness;
    if (spread)
        emit spreadLightnessChange(lightness, false);
    else
        emit screenLightnessChanged();
}

void ScreenModel::setScreenSaturation(int saturation, bool spread)
{
    m_screens[m_currentScreen].saturation = saturation;
    if (spread)
        emit spreadSaturationChange(saturation, false);
    else
        emit screenSaturationChanged();
}

