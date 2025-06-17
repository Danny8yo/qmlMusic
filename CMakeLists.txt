cmake_minimum_required(VERSION 3.16)

project(qmltest VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(PkgConfig REQUIRED)

# 这行会查找 TagLib 并设置 TAGLIB_LIBRARIES 和 TAGLIB_INCLUDE_DIRS 变量
pkg_check_modules(TAGLIB REQUIRED taglib)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appqmltest
    main.cpp
)

qt_add_qml_module(appqmltest
    URI qmltest
    VERSION 1.0
    QML_FILES
        Main.qml
    SOURCES song.h song.cpp
    SOURCES MusicScanner.h
    SOURCES MusicScanner.cpp
    SOURCES playlist.cpp playlist.h
)

set_target_properties(appqmltest PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# --- 这是需要修改的地方 ---
# 将 ${TAGLIB_LIBRARIES} 添加到链接列表
target_link_libraries(appqmltest
    PRIVATE
    Qt6::Quick
    ${TAGLIB_LIBRARIES}
)
# --- 修改结束 ---

# (可选但推荐) 明确添加 TagLib 的头文件路径
target_include_directories(appqmltest PRIVATE ${TAGLIB_INCLUDE_DIRS})

include(GNUInstallDirs)
install(TARGETS appqmltest
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)




# cmake_minimum_required(VERSION 3.16)

# project(qmltest VERSION 0.1 LANGUAGES CXX)

# set(CMAKE_CXX_STANDARD_REQUIRED ON)

# find_package(Qt6 REQUIRED COMPONENTS Quick)
# find_package(PkgConfig REQUIRED)
# pkg_check_modules(TAGLIB REQUIRED taglib)

# qt_standard_project_setup(REQUIRES 6.8)

# qt_add_executable(appqmltest
#     main.cpp
# )

# qt_add_qml_module(appqmltest
#     URI qmltest
#     VERSION 1.0
#     QML_FILES
#         Main.qml
#         SOURCES song.h song.cpp
#         # QML_FILES myjs.js
# )

# # Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# # If you are developing for iOS or macOS you should consider setting an
# # explicit, fixed bundle identifier manually though.
# set_target_properties(appqmltest PROPERTIES
# #    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appqmltest
#     MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
#     MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
#     MACOSX_BUNDLE TRUE
#     WIN32_EXECUTABLE TRUE
# )

# target_link_libraries(appqmltest
#     PRIVATE Qt6::Quick
# )

# include(GNUInstallDirs)
# install(TARGETS appqmltest
#     BUNDLE DESTINATION .
#     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
#     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
# )
