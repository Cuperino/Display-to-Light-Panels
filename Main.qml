// Copyright (C) 2023 Javier O. Cordero Pérez
// SPDX-License-Identifier: GPL-3.0-only

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import QtCore
import QtQuick.Controls.Universal

Item {
    id: root
    property bool showAbout: false
    Settings {
        category: "panels"
        property alias windowCount: panels.model
    }
    Instantiator {
        id: panels
        model: 1
        delegate: Window {
            id: lightPanel
            width: 640
            height: 480
            minimumWidth: controls.enabled ? controlsGroupBox.implicitWidth : 64
            minimumHeight: controls.enabled ? controlsGroupBox.implicitHeight : 64
            title: index===-1 || panels.count<2 ? qsTr("Light Panels") : qsTr("Light Panels (%0)").arg(index + 1)
            visible: true
            color: Qt.hsla(hue.value/360, saturation.value/255, lightness.value/255)
            flags: Qt.WindowFullscreenButtonHint | (windowZ.currentIndex ? (windowZ.currentIndex === 1 ? Qt.WindowStaysOnTopHint : Qt.WindowStaysOnBottomHint) : 0) | (frameless.checked ? Qt.FramelessWindowHint : 0)
            property bool fullscreen: false
            onClosing: {
                windowSettings.sync();
                // if (panels.model>1)
                //     --panels.model;
            }
            onScreenChanged: {
                bindToScreen();
            }
            Component.onCompleted: {
                bindToScreen();
            }
            function bindToScreen() {
                for (let i=0; i<Qt.application.screens.length; i++)
                    if (screen.name === Qt.application.screens[i].name) {
                        hue.value = Qt.binding(function() { return screens.itemAt(i).hue})
                        lightness.value = Qt.binding(function() { return screens.itemAt(i).lightness; })
                        saturation.value = Qt.binding(function() { return screens.itemAt(i).saturation; })
                    }
            }
            function reset() {
                root.showAbout = false;
                lightPanel.width = 640;
                lightPanel.height = 480;
                lightPanel.x = (screen.width - lightPanel.width) / 2;
                lightPanel.y = (screen.height - lightPanel.height) / 2;
                hue.value = 180;
                lightness.value = 250;
                saturation.value = 255;
                fullScreen.checked = false;
                frameless.checked = false;
                windowZ.currentIndex = 0;
                opacityAnimation.reverse = false;
                controls.yOffset = 0.86
                root.showAbout = false;
            }
            Settings {
                id: windowSettings
                category: "n" + index.toString()
                property alias wX: lightPanel.x
                property alias wY: lightPanel.y
                property alias wW: lightPanel.width
                property alias wH: lightPanel.height
                property alias fullscreen: fullScreen.checked
                property alias frameless: frameless.checked
                property alias z: windowZ.currentIndex
                property alias opacity: opacityAnimation.reverse
                property alias yOffset: controls.yOffset
            }
            MouseArea {
                id: showHideControls
                anchors.fill: parent
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                property alias root: lightPanel
                property int prevX: 0
                property int prevY: 0
                property bool moved: false
                onPressed: (mouse) => {
                    if (Qt.platform.os!=="android") {
                        prevX = mouse.x;
                        prevY = mouse.y;
                        moved = false;
                    }
                }
                onPositionChanged: (mouse) => {
                    if (Qt.platform.os!=="android") {
                        var deltaX = mouse.x - prevX;
                        root.x += deltaX;
                        prevX = mouse.x - deltaX;
                        var deltaY = mouse.y - prevY
                        root.y += deltaY;
                        prevY = mouse.y - deltaY;
                        moved = true;
                    }
                }
                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        if (timer.running)
                        {
                            timer.stop()
                        }
                        else {
                            frameless.checked = !frameless.checked;
                            timer.restart()
                        }
                    }
                }
                onDoubleClicked: {
                    toggle();
                }
                function toggle() {
                   if (!opacityAnimation.running && !moved) {
                        if (opacityAnimation.reverse)
                            opacityAnimation.reverse = false;
                        else
                            opacityAnimation.reverse = true;
                        opacityAnimation.running = true;
                    }
                }
                Timer{
                    id: clickTimer
                    interval: 200
                    onTriggered: singleClick()
                }
                OpacityAnimator {
                    id: opacityAnimation
                    property bool reverse: false
                    from: reverse ? 1 : 0;
                    to: reverse ? 0 : 1;
                    duration: 500
                    running: !reverse
                    target: controls;
                    onStarted: {
                        controls.enabled = true;
                    }
                    onFinished: {
                        if (lightPanel.fullscreen) {
                            if (reverse)
                                controls.enabled = false;
                            else
                                controls.enabled = true;
                            if (lightPanel.fullscreen)
                                lightPanel.showFullScreen();
                        }
                        else {
                            if (reverse)
                                controls.enabled = false;
                            else
                                controls.enabled = true;
                            if (!lightPanel.fullscreen)
                                lightPanel.showNormal();
                        }
                    }
                }
                Item {
                    id: controls
                    property double yOffset: 0.86
                    y: (lightPanel.height - controlsGroupBox.height - 2 * controlsGroupBox.anchors.margins) * yOffset
                    height: controlsGroupBox.implicitHeight
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    layer.enabled: true
                    layer.smooth: true
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.SplitVCursor
                        drag.target: controls
                        drag.axis: Drag.YAxis
                        drag.smoothed: false
                        drag.minimumY: 0
                        drag.maximumY: lightPanel.height - controlsGroupBox.height - 2 * controlsGroupBox.anchors.margins
                        onReleased: {
                            controls.yOffset = controls.y / drag.maximumY;
                        }
                        GroupBox {
                            id: controlsGroupBox
                            title: showAbout ? qsTr("Light Panels, © Javier Cordero, Licensed GPL-3.0") : qsTr("Panel Settings")
                            anchors {
                                fill: parent
                                margins: 5
                            }
                            Universal.foreground: lightness.value < 64 ? "#FFF" : "#000"
                            Universal.background: lightness.value < 64 ? Universal.Steel : "#FFF"
                            Universal.accent: lightness.value < 64 ? Universal.Steel : Universal.Cobalt
                            ColumnLayout {
                                id: columnLayout
                                anchors.fill: parent
                                RowLayout {
                                    id: hue
                                    property int value: 180
                                    Label {
                                        text: qsTr("Hue")
                                    }
                                    Slider {
                                        id: hueSlider
                                        value: hue.value
                                        to: 360
                                        Layout.fillWidth: true
                                        onValueChanged: {
                                            hue.value = value;
                                        }
                                        NumberAnimation on value {
                                            running: root.showAbout
                                            from: hueSlider.to
                                            to: hueSlider.from
                                            loops: 3
                                            duration: 3600
                                            property int tHue: 0
                                            property int tLight: 0
                                            property int tSat: 0
                                            onStarted: {
                                                tHue = hue.value;
                                                tLight = lightness.value;
                                                tSat = saturation.value;
                                                lightness.value = 248;
                                                saturation.value = 255;
                                                hueSlider.enabled = false;
                                            }
                                            onStopped: {
                                                root.showAbout = false;
                                                hueSlider.enabled = true;
                                                hue.value = tHue;
                                                lightness.value = tLight;
                                                saturation.value = tSat;
                                            }
                                        }
                                    }
                                    SpinBox {
                                        id: hueSpinBox
                                        value: hue.value
                                        editable: true
                                        to: 360
                                        onValueChanged: {
                                            hue.value = value;
                                        }
                                    }
                                }
                                RowLayout {
                                    id: lightness
                                    property int value: 250
                                    Label {
                                        text: qsTr("Lightness")
                                    }
                                    Slider {
                                        id: lightnessSlider
                                        value: lightness.value
                                        to: 255
                                        Layout.fillWidth: true
                                        onValueChanged: {
                                            lightness.value = value;
                                        }
                                    }
                                    SpinBox {
                                        id: lightnessSpinBox
                                        value: lightness.value
                                        editable: true
                                        to: 255
                                        onValueChanged: {
                                            lightness.value = value;
                                        }
                                    }
                                }
                                RowLayout {
                                    id: saturation
                                    property int value: 255
                                    Label {
                                        text: qsTr("Saturation")
                                    }
                                    Slider {
                                        id: saturationSlider
                                        value: saturation.value
                                        to: 255
                                        Layout.fillWidth: true
                                        onValueChanged: {
                                            saturation.value = value;
                                        }
                                    }
                                    SpinBox {
                                        id: saturationSpinBox
                                        value: saturation.value
                                        editable: true
                                        to: 255
                                        onValueChanged: {
                                            saturation.value = value;
                                        }
                                    }
                                }
                                RowLayout {
                                    CheckBox {
                                        id: fullScreen
                                        enabled: Qt.platform.os!=="osx"
                                        visible: enabled
                                        text: qsTr("Fullscreen")
                                        checked: lightPanel.fullscreen
                                        onClicked: {
                                            if (lightPanel.fullscreen)
                                                lightPanel.showNormal();
                                            else
                                                lightPanel.showFullScreen();
                                            lightPanel.fullscreen = !lightPanel.fullscreen;
                                        }
                                    }
                                    CheckBox {
                                        id: frameless
                                        text: qsTr("Frameless")
                                        Component.onCompleted: {
                                            if (Qt.platform.os==="linux" && !fullScreen.checked && checked) {
                                                lightPanel.showFullScreen();
                                                frameless.checked = false;
                                                kwinHack.start()
                                            }
                                        }
                                        Timer {
                                            // Workaround to restore decorations toggle on KDE Kwin
                                            id: kwinHack
                                            interval: 0
                                            onTriggered: {
                                                lightPanel.showNormal();
                                                frameless.checked = true;
                                            }
                                        }
                                    }
                                    Button {
                                        text: qsTr("Reset")
                                        onClicked: {
                                            lightPanel.reset();
                                        }
                                    }
                                    Button {
                                        text: "ℹ️"
                                        onClicked: {
                                            root.showAbout = !root.showAbout;
                                        }
                                    }
                                    Button {
                                        text: qsTr("White")
                                        enabled: lightness.value!=255
                                        onClicked: {
                                            lightness.value = 255
                                        }
                                    }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Button {
                                        visible: Qt.platform.os!=="android" && Qt.platform.os!=="ios"
                                        text: qsTr("Add Window")
                                        onClicked: {
                                            ++panels.model;
                                        }
                                    }
                                    Button {
                                        enabled: panels.model>1
                                        text: qsTr("Clear")
                                        onClicked: {
                                            const n = panels.model;
                                            for (let i=0; i<n; i++)
                                                panels.objectAt(i).reset();
                                            panels.model = 1;
                                        }
                                    }
                                    ComboBox {
                                        id: windowZ
                                        model: Qt.platform.os==="osx" ? ["Normal", "Always in front"] : ["Normal", "Always in front", "Always behind"]
                                        Layout.fillWidth: true
                                    }
                                    Item {
                                        Layout.fillWidth: true
                                    }
                                    Button {
                                        text: "💡" // Lightbulb emoji
                                        onClicked: {
                                            showHideControls.toggle();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Repeater {
        id: screens
        model: Qt.application.screens
        delegate: Item {
            id: screenMetadata
            property string name: model.name
            property int hue: 180
            property int lightness: 250
            property int saturation: 255
            Settings {
                id: colorSettings
                category: "s" + screenMetadata.name
                property alias hue: screenMetadata.hue
                property alias lightness: screenMetadata.lightness
                property alias saturation: screenMetadata.saturation
            }
        }
        onItemRemoved: {
            colorSettings.sync();
        }
    }
}
