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

    Q_PROPERTY(const QString &screenName READ currentScreen WRITE setCurrentScreen NOTIFY currentScreenChanged FINAL)
    Q_PROPERTY(int hue READ screenHue WRITE setScreenHue NOTIFY screenHueChanged FINAL)
    Q_PROPERTY(int lightness READ screenLightness WRITE setScreenLightness NOTIFY screenLightnessChanged FINAL)
    Q_PROPERTY(int saturation READ screenSaturation WRITE setScreenSaturation NOTIFY screenSaturationChanged FINAL)
    Q_PROPERTY(bool ready MEMBER m_ready NOTIFY screenHueChanged FINAL)
public:
    explicit ScreenModel(QObject* parent = nullptr);

    QString currentScreen();
    int screenHue();
    int screenLightness();
    int screenSaturation();

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

    void readyChanged();

private:
    QMap<QString, ColorProperties> m_screens;
    QString m_currentScreen;
    bool m_ready;
    std::shared_ptr<InternalMessageBroker> m_mb;
    void initializeScreenMap();
};
