cmake_minimum_required(VERSION 3.16)

project(DisplayToLightPanels
    VERSION 0.2.0
    DESCRIPTION "Convert monitors into light panels"
    HOMEPAGE_URL "https://cuperino.com/lightpanels"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS
    Quick
    Widgets
)

qt_standard_project_setup()

qt_add_executable(${PROJECT_NAME}
    main.cpp
)

qt_add_qml_module(${PROJECT_NAME}
    URI DisplayToLightPanel
    RESOURCE_PREFIX /qt/qml/
    VERSION 1.0
    NO_PLUGIN
    IMPORTS "QtQuick.Controls.Universal"
    DEPENDENCIES
    QtQuick
    QML_FILES
    Main.qml
    SOURCES
    screenmodel.h screenmodel.cpp
    internalmessagebroker.hpp
    # ENABLE_TYPE_COMPILER
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER com.cuperino.lightpanels
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    QML_CACHEGEN_DIRECT_CALLS ON
    QT_QMLCACHEGEN_EXECUTABLE qmlsc
    QT_QMLCACHEGEN_ARGUMENTS "--verbose;--direct-calls"
    # QT_QMLCACHEGEN_ARGUMENTS "--verbose;--static;--direct-calls"
)

set_source_files_properties(Global.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    Qt::Quick
    Qt::QuickPrivate
    Qt::Widgets
)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
