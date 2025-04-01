// Copyright (C) 2023-2025 Javier O. Cordero Pérez
// SPDX-License-Identifier: GPL-3.0-or-later

// pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.12

import QtQml.Models 2.15
import Qt.labs.platform 1.1
import Qt.labs.settings 1.1
// import QtCore // 6.5

import com.cuperino.lightpanel 1.0

Item {
    id: root
    property bool showAbout: false
    property int panelCount: 1
    Settings {
        category: "panels"
        property alias panelCount: root.panelCount
    }
    Timer {
        id: startupTimer
        property int w: 0
        interval: 1
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            panels.model.append({});
            if (++w===root.panelCount)
                stop();
        }
    }
    Instantiator {
        id: panels
        property int skips: 0
        function addPanel() {
            panels.model.append({});
            root.panelCount++;
        }
        model: ListModel {}
        delegate: Window {
            id: lightPanel
            width: 640
            height: 480
            minimumWidth: controls.enabled ? controlsGroupBox.implicitWidth : 64
            minimumHeight: controls.enabled ? controlsGroupBox.implicitHeight : 64
            title: qsTr("Light Panels <%0> ").arg(lightPanel.screen.name)
            visible: !skip
            color: Qt.hsla(screenModel.hue/360, screenModel.saturation/255, screenModel.lightness/255)
            flags: Qt.WindowFullscreenButtonHint | (windowZ.currentIndex ? (windowZ.currentIndex === 1 ? Qt.WindowStaysOnTopHint : Qt.WindowStaysOnBottomHint) : 0) | (frameless.checked ? Qt.FramelessWindowHint : 0)
            required property int index
            property bool fullscreen: false
            property bool finishClosing: false
            property bool skip: false
            onClosing: (close) => {
                if (root.panelCount===panels.skips+1)
                    saveAndQuit();
                else if (finishClosing) {
                    skip = true;
                    panels.skips++;
                }
                else {
                    closingDialog.open();
                    close.accepted = false;
                }
            }
            onScreenChanged: bindToScreen();
            Component.onCompleted: {
                bindToScreen();
                if (!opacityAnimation.visible)
                    textAnimation.trigger();
                if (skip) {
                    panels.skips++;
                    if (panels.skips===root.panelCount) {
                        lightPanel.clearAll();
                        panels.addPanel();
                    }
                }
            }
            function clearAll() {
                startupTimer.stop();
                root.panelCount = 1;
                screenModel.clear(panels.model.count);
                if (index > 0)
                    panels.model.remove(0, index);
                if (panels.model.count-index-1)
                    panels.model.remove(index+1, panels.model.count-index-1);
            }
            function bindToScreen() {
                const screen = lightPanel.screen.name;
                screenSettings.category = screen + "s";
                screenModel.screenName = screen;
            }
            function reset() {
                root.showAbout = false;
                lightPanel.width = 640;
                lightPanel.height = 480;
                lightPanel.x = (Screen.width - lightPanel.width) / 2;
                lightPanel.y = (Screen.height - lightPanel.height) / 2;
                screenModel.hue = 180;
                screenModel.lightness = 250;
                screenModel.saturation = 255;
                fullScreen.checked = false;
                frameless.checked = false;
                windowZ.currentIndex = 0;
                opacityAnimation.reverse = false;
                controls.yOffset = 0.86
                root.showAbout = false;
            }
            function toggleFullScreen() {
                if (fullscreen)
                    showNormal();
                else
                    showFullScreen();
                fullscreen = !fullscreen;
            }
            function saveAndQuit() {
                windowSettings.sync();
                screenSettings.sync();
                Qt.quit();
            }
            Settings {
                id: windowSettings
                category: "n" + index
                property alias wX: lightPanel.x
                property alias wY: lightPanel.y
                property alias wW: lightPanel.width
                property alias wH: lightPanel.height
                property alias fullscreen: fullScreen.checked
                property alias frameless: frameless.checked
                property alias z: windowZ.currentIndex
                property alias opacity: opacityAnimation.reverse
                property alias yOffset: controls.yOffset
                property alias screenName: screenModel.screenName
                property alias skip: lightPanel.skip
            }
            Universal.foreground: screenModel.lightness < 92 ? "#FFF" : "#000"
            Universal.background: screenModel.lightness < 92 ? Universal.Steel : "#FFF"
            Universal.accent: screenModel.lightness < 92 ? Universal.Steel : Universal.Cobalt
            ScreenModel {
                id: screenModel
                lightness: 250
                saturation: 255
                screenName: lightPanel.screen.name
                NumberAnimation on hue {
                    running: root.showAbout
                    from: hueSlider.to
                    to: hueSlider.from
                    loops: 3
                    duration: 3600
                    property int tHue: 0
                    property int tLight: 0
                    property int tSat: 0
                    onStarted: {
                        tHue = screenModel.hue;
                        tLight = screenModel.lightness;
                        tSat = screenModel.saturation;
                        screenModel.lightness = 248;
                        screenModel.saturation = 255;
                        hueSlider.enabled = false;
                    }
                    onStopped: {
                        root.showAbout = false;
                        hueSlider.enabled = true;
                        screenModel.hue = tHue;
                        screenModel.lightness = tLight;
                        screenModel.saturation = tSat;
                    }
                }
            }
            MessageDialog {
                id: closingDialog
                title: qsTr("Closing Light Panel")
                informativeText: qsTr("Would you like to save and quit, close the window, or cancel?")
                modality: Qt.ApplicationModal
                buttons: MessageDialog.Save | MessageDialog.Close | MessageDialog.Cancel
                onSaveClicked: {
                    lightPanel.saveAndQuit();
                }
                onCloseClicked: {
                    lightPanel.finishClosing = true;
                    lightPanel.close();
                }
            }
            MouseArea {
                id: instructions
                visible: opacity
                enabled: visible
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 38
                acceptedButtons: Qt.NoButton
                hoverEnabled: true
                onEntered: flipable.flipped = true
                onExited: flipable.flipped = false
                Flipable {
                    id: flipable
                    anchors.fill: parent
                    property bool flipped: false
                    front: Rectangle {
                        color: lightPanel.color
                        anchors.fill: parent
                        Label {
                            text: opacityAnimation.visible ? qsTr("Double click to show controls") : qsTr("Double click to hide controls")
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.margins: 8
                        }
                    }
                    back: Rectangle {
                        color: lightPanel.color
                        anchors.fill: parent
                        Label {
                            text: frameless.checked ? qsTr("Middle click to show frame") : qsTr("Middle click to hide frame")
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.margins: 8
                        }
                    }
                    transform: Rotation {
                        id: flipRotation
                        origin.x: flipable.width/2
                        origin.y: flipable.height/2
                        axis.x: 0; axis.y: 1; axis.z: 0
                        angle: 0
                    }
                    states: State {
                        name: "back"
                        when: flipable.flipped
                        PropertyChanges {
                            target: flipRotation;
                            angle: 180
                        }
                    }
                    transitions: Transition {
                        NumberAnimation {
                            target: flipRotation;
                            property: "angle";
                            duration: 250
                        }
                    }
                }
            }
            MouseArea {
                id: showHideControls
                anchors.fill: parent
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                property alias root: lightPanel
                property int prevX: 0
                property int prevY: 0
                property bool moved: false
                onPressed: (mouse) => {
                    if (Qt.platform.os!=="android" && Qt.platform.os!=="ios") {
                        prevX = mouse.x;
                        prevY = mouse.y;
                        moved = false;
                    }
                }
                onPositionChanged: (mouse) => {
                    if (Qt.platform.os!=="android" && Qt.platform.os!=="ios") {
                        var deltaX = mouse.x - prevX;
                        root.x += deltaX;
                        prevX = mouse.x - deltaX;
                        var deltaY = mouse.y - prevY
                        root.y += deltaY;
                        prevY = mouse.y - deltaY;
                        moved = true;
                    }
                }
                onClicked: (mouse) => {
                    if (mouse.button === Qt.MiddleButton)
                        frameless.toggle();
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
                Timer {
                    id: clickTimer
                    interval: 200
                    onTriggered: showHideControls.clicked(null)
                }
                Settings {
                    id: screenSettings
                    // Append suffix in case screen returns an empty string
                    category: screenModel.screenName + "s"
                    property alias hue: screenModel.hue
                    property alias lightness: screenModel.lightness
                    property alias saturation: screenModel.saturation
                }
                OpacityAnimator {
                    id: opacityAnimation
                    property bool reverse: !controls.enabled
                    property alias visible: opacityAnimation.reverse
                    from: reverse ? 1 : 0;
                    to: reverse ? 0 : 1;
                    duration: 500
                    running: !reverse
                    target: controls;
                    onStarted: controls.enabled = true;
                    onFinished: {
                        textAnimationDelay.interval = 8000
                        if (lightPanel.fullscreen) {
                            if (reverse) {
                                controls.enabled = false;
                                textAnimation.start();
                            }
                            else
                                controls.enabled = true;
                            if (lightPanel.fullscreen)
                                lightPanel.showFullScreen();
                        }
                        else {
                            if (reverse) {
                                controls.enabled = false;
                                textAnimation.trigger();
                            }
                            else
                                controls.enabled = true;
                            if (!lightPanel.fullscreen)
                                lightPanel.showNormal();
                        }
                    }
                }
                OpacityAnimator {
                    id: textAnimation
                    property bool ranOnce: false
                    from: 1
                    to: 0
                    duration: 500
                    target: instructions;
                    function trigger() {
                        if (!ranOnce) {
                            ranOnce = true;
                            textAnimationDelay.start();
                        }
                    }
                }
                Timer {
                    id: textAnimationDelay
                    running: true
                    interval: 5000
                    onTriggered: textAnimation.start();
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
                    opacity: 0
                    enabled: false
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
                            title: root.showAbout ? qsTr("Display to Light Panel, © 2023-2025 Javier Cordero, Licensed GPL-3.0") : qsTr("Panel Settings")
                            anchors {
                                fill: parent
                                margins: 5
                            }
                            ColumnLayout {
                                id: columnLayout
                                anchors.fill: parent
                                RowLayout {
                                    id: hue
                                    Label {
                                        text: qsTr("Hue")
                                    }
                                    Slider {
                                        id: hueSlider
                                        value: screenModel.hue
                                        to: 360
                                        Layout.fillWidth: true
                                        onValueChanged: {
                                            if (pressed)
                                                screenModel.hue = value;
                                        }
                                    }
                                    SpinBox {
                                        id: hueSpinBox
                                        value: screenModel.hue
                                        editable: true
                                        to: 360
                                        onValueChanged: {
                                            if (down.pressed || up.pressed)
                                                screenModel.hue = value;
                                        }
                                    }
                                }
                                RowLayout {
                                    id: lightness
                                    Label {
                                        text: qsTr("Lightness")
                                    }
                                    Slider {
                                        id: lightnessSlider
                                        value: screenModel.lightness
                                        to: 255
                                        Layout.fillWidth: true
                                        onValueChanged: {
                                            if (pressed)
                                                screenModel.lightness = value;
                                        }
                                    }
                                    SpinBox {
                                        id: lightnessSpinBox
                                        value: screenModel.lightness
                                        editable: true
                                        to: 255
                                        onValueChanged: {
                                            if (down.pressed || up.pressed)
                                                screenModel.lightness = value;
                                        }
                                    }
                                }
                                RowLayout {
                                    id: saturation
                                    Label {
                                        text: qsTr("Saturation")
                                    }
                                    Slider {
                                        id: saturationSlider
                                        value: screenModel.saturation
                                        to: 255
                                        Layout.fillWidth: true
                                        onValueChanged: {
                                            if (pressed)
                                                screenModel.saturation = value;
                                        }
                                    }
                                    SpinBox {
                                        id: saturationSpinBox
                                        value: screenModel.saturation
                                        editable: true
                                        to: 255
                                        onValueChanged: {
                                            if (down.pressed || up.pressed)
                                                screenModel.saturation = value;
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
                                        onToggled: lightPanel.toggleFullScreen()
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
                                        enabled: screenModel.lightness !== 255
                                        onClicked: {
                                            screenModel.lightness = 255
                                        }
                                    }
                                }
                                RowLayout {
                                    visible: Qt.platform.os!=="android" && Qt.platform.os!=="ios"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Button {
                                        text: qsTr("Add Window")
                                        onClicked: panels.addPanel()
                                    }
                                    Button {
                                        enabled: panels.model.count > 1
                                        text: qsTr("Clear")
                                        onClicked: lightPanel.clearAll()
                                    }
                                    ComboBox {
                                        id: windowZ
                                        // readonly property list<string> stringList: Qt.platform.os==="osx" ? [qsTr("Normal"), qsTr("Always in front")] : [qsTr("Normal"), qsTr("Always in front"), qsTr("Always behind")]
                                        // model: stringList
                                        model: Qt.platform.os==="osx" ? [qsTr("Normal"), qsTr("Always in front")] : [qsTr("Normal"), qsTr("Always in front"), qsTr("Always behind")]
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
            Shortcut {
                sequence: StandardKey.New
                context: Qt.WindowShortcut
                onActivated: panels.addPanel()
            }
            Shortcut {
                sequences: [StandardKey.FullScreen]
                context: Qt.WindowShortcut
                onActivated: lightPanel.toggleFullScreen()
            }
            Shortcut {
                sequence: StandardKey.Cancel
                context: Qt.WindowShortcut
                onActivated: frameless.toggle()
            }
            Shortcut {
                sequence: StandardKey.Close
                context: Qt.WindowShortcut
                onActivated: {
                    lightPanel.finishClosing = true;
                    lightPanel.close();
                }
            }
        }
    }
    Shortcut {
        sequence: StandardKey.Quit
        context: Qt.ApplicationShortcut
        onActivated: Qt.quit()
    }
}
