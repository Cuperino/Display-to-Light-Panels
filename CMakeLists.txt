# Copyright (C) 2023-2025 Javier O. Cordero Pérez
# SPDX-License-Identifier: GPL-3.0-or-later

cmake_minimum_required(VERSION 3.22)

project(DisplayToLightPanels
    VERSION 0.2.0
    DESCRIPTION "Convert monitors into light panels"
    HOMEPAGE_URL "https://cuperino.com/lightpanels"
    LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)

option(QT_VERSION_MAJOR "Set Qt major version")
if (NOT QT_VERSION_MAJOR)
    find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)
endif()

find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS
    Gui
    Quick
    Widgets
)

if(${QT_VERSION_MAJOR} EQUAL 6)
    # qt_standard_project_setup()
    qt_add_executable(${PROJECT_NAME}
        main.cpp
    )
    qt_add_qml_module(${PROJECT_NAME}
        URI com.cuperino.lightpanel
        RESOURCE_PREFIX /qt/qml/
        VERSION 1.0
        NO_PLUGIN
        IMPORTS "QtQuick.Controls.Universal"
        DEPENDENCIES
        QtQuick
        QML_FILES
        main.qml
        SOURCES
        screenmodel.h screenmodel.cpp
        internalmessagebroker.hpp
        # ENABLE_TYPE_COMPILER
    )
else()
    set(CMAKE_AUTORCC ON)
    add_executable(${PROJECT_NAME} "main.cpp"
        "screenmodel.h"
        "screenmodel.cpp"
        "internalmessagebroker.hpp"
        "qml.qrc"
    )
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER com.cuperino.lightpanel
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    # QT_QMLCACHEGEN_DIRECT_CALLS ON
    QT_QMLCACHEGEN_EXECUTABLE qmlsc
    QT_QMLCACHEGEN_ARGUMENTS "--verbose;--static"
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Quick
    # Qt${QT_VERSION_MAJOR}::QuickPrivate
    Qt${QT_VERSION_MAJOR}::Widgets
)


set_source_files_properties(Global.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)


include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
