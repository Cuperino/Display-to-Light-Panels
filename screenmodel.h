// Copyright (C) 2023-2025 Javier O. Cordero Pérez
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

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
    void setScreenHue(const int hue, const bool spread=true, const QString &screenName="s");
    void setScreenLightness(const int lightness, const bool spread=true, const QString &screenName="s");
    void setScreenSaturation(const int saturation, const bool spread=true, const QString &screenName="s");

    Q_INVOKABLE void clear(const int length);

signals:
    void currentScreenChanged();

    void spreadHueChange(int hue, bool baseCase, const QString &);
    void spreadLightnessChange(int lightness, bool baseCase, const QString &);
    void spreadSaturationChange(int saturation, bool baseCase, const QString &);

    void screenHueChanged();
    void screenLightnessChanged();
    void screenSaturationChanged();

private:
    void initializeScreenMap();
    std::shared_ptr<InternalMessageBroker> m_mb;
    QString m_currentScreen;
    QMap<QString, ColorProperties> m_screens;
};
