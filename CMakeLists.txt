cmake_minimum_required(VERSION 3.16)

project(DisplayToLightPanel
    VERSION 0.2.0
    DESCRIPTION "Convert monitors into light panels"
    HOMEPAGE_URL "https://cuperino.com/lightpanels"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick)

qt_standard_project_setup()

qt_add_executable(appDisplayToLightPanel
    main.cpp
)

qt_add_resources(appDisplayToLightPanel "configuration"
    PREFIX "/"
    FILES
        qtquickcontrols2.conf
)

qt_add_qml_module(appDisplayToLightPanel
    URI DisplayToLightPanel
    RESOURCE_PREFIX /qt/qml/
    VERSION 1.0
    NO_PLUGIN
    IMPORTS "QtQuick.Controls.Universal"
    QML_FILES Main.qml
    # ENABLE_TYPE_COMPILER
    SOURCES screenmodel.h screenmodel.cpp internalmessagebroker.hpp
)

set_target_properties(appDisplayToLightPanel PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER com.cuperino.DisplayToLightPanel
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    QML_CACHEGEN_DIRECT_CALLS ON
)

target_link_libraries(appDisplayToLightPanel
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appDisplayToLightPanel
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
