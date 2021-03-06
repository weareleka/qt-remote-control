TEMPLATE = app
QT += qml quick widgets svg
QT += gui
QT += opengl
!no_desktop: QT += widgets
#QT += sql
SOURCES += main.cpp \
    fileio.cpp \
    Stabilization.cpp \
    filters.cpp \
    runningaverage.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    android/AndroidManifest.xml \
    android/res/values/libs.xml \
    android/build.gradle

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

HEADERS += \
    fileio.h \
    Stabilization.h \
    Filters.h \
    RunningAverage.h
