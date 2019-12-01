#
# Min version of CMake
#
cmake_minimum_required(VERSION 3.8)

#
# Project
#
project(qmldev
	VERSION 0.1.0
	LANGUAGES CXX
	DESCRIPTION "QML development helper with support for automatic hot reloading."
)

#
# Setup CMake, Qt, load our utilities, etc.
#
include (cmake/Setup.cmake)
include (cmake/CMakeUtils/Qt.cmake)
include (cmake/CMakeUtils/Utils.cmake)

#
# Utils
#
add_subdirectory (QtUtils)

#
# The library
#
add_executable (qmldev WIN32
	Main.cpp
)

#
# Include directories
#
target_include_directories (qmldev
	PRIVATE
		QtUtils
)

#
# compiler's requirements
#
target_compile_features (qmldev
	PRIVATE
		cxx_std_17
)

#
# libs
#
target_link_libraries(qmldev
	PRIVATE
		Qt5::Qml
		Qt5::Quick
		Qt5::QuickControls2
		Qt5::Widgets

		# QtUtils
		QtUtils
)

#
# Compile definitions
#
target_compile_definitions (qmldev
	PRIVATE
		# Qt/QML debug stuff
		$<$<NOT:$<CONFIG:Release>>:QT_QML_DEBUG>
		$<$<CONFIG:Release>:QT_NO_DEBUG>
		$<$<CONFIG:Release>:QT_NO_DEBUG_OUTPUT>
		$<$<CONFIG:Release>:QT_NO_INFO_OUTPUT>
		$<$<CONFIG:Release>:QT_NO_WARNING_OUTPUT>

		# Build type
		$<$<CONFIG:Release>:RELEASE>
		$<$<NOT:$<CONFIG:Release>>:DEBUG>

		# Platforms
		$<$<PLATFORM_ID:Windows>:WINDOWS>
		$<$<PLATFORM_ID:Linux>:LINUX>
		$<$<PLATFORM_ID:Darwin>:MACOS>

		# Compilers
		$<$<CXX_COMPILER_ID:MSVC>:MSVC>
		$<$<CXX_COMPILER_ID:Clang>:CLANG>
		$<$<CXX_COMPILER_ID:GNU>:GCC>

		# Disable some annoying warnings
		# note that Clang on Windows uses the same STL as MSVC, so it suffers from the same warnings
		$<$<PLATFORM_ID:Windows>:_CRT_SECURE_NO_WARNINGS>

		# QML debug
		$<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

#
# Compile options
#
target_compile_options (qmldev
	PRIVATE
		# Warning configurations
		$<$<CXX_COMPILER_ID:MSVC>:/W4 $<$<BOOL:${WARNINGS_AS_ERRORS}>:/WX>>
		$<$<CXX_COMPILER_ID:Clang>:-Wall $<$<BOOL:${WARNINGS_AS_ERRORS}>:-Werror>>
		$<$<CXX_COMPILER_ID:GNU>:-Wall $<$<BOOL:${WARNINGS_AS_ERRORS}>:-Werror>>
)

#
# Installation
#
install_qt_target (qmldev "${CMAKE_CURRENT_SOURCE_DIR}/QmlDeploy"
	RUNTIME DESTINATION .
	LIBRARY DESTINATION .
	ARCHIVE DESTINATION .
)
install (FILES
	Main.qml
	Error.qml
	DESTINATION .
)
