#
# Min version of CMake
#
cmake_minimum_required(VERSION 3.8)

#
# Project
#
project(qmldev)

#
# totally remove warnings.
#
string (REGEX REPLACE "(/W[^ ]+)|(-W[123])" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

#
# Find Qt.
#
find_path (QT_DIR Qt5
	HINTS
		"${QT_DIR}"
		"C:/Development/Libs/Qt/5.12.3"
		"D:/Development/Libs/Qt/5.12.3"
		"~/Development/Libs/Qt/5.12.3"
	PATH_SUFFIXES
		"msvc2017_64/lib/cmake"
		"gcc_64/lib/cmake"
		"clang_64/lib/cmake"
)

if (NOT QT_DIR)
	message (FATAL_ERROR "Couldn't find Qt. Use QT_DIR variable to point to a valid Qt install.")
endif ()

set (CMAKE_PREFIX_PATH ${QT_DIR})
find_package (Qt5 5.12
	COMPONENTS
		Qml
		Quick
		QuickControls2
		Widgets
	REQUIRED
)

#
# Auto moc and rcc
#
set (CMAKE_AUTOMOC ON)
set (CMAKE_AUTORCC ON)

#
# Utils
#
add_subdirectory (QtUtils)

#
# The library
#
add_executable (qmldev WIN32
	Main.cpp

	# needed for moc
	QtUtils/QuickView.cpp
	QtUtils/QuickView.h
	QtUtils/Settings.cpp
	QtUtils/Settings.h
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
		# Platforms
		$<$<PLATFORM_ID:Windows>:WINDOWS>

		# Compilers
		$<$<CXX_COMPILER_ID:MSVC>:MSVC>
		$<$<CXX_COMPILER_ID:Clang>:CLANG>

		# Some warnings
		$<$<CXX_COMPILER_ID:MSVC>:_CRT_SECURE_NO_WARNINGS>

		# QML debug
		$<$<NOT:$<CONFIG:Release>>:QT_QML_DEBUG>
		$<$<NOT:$<CONFIG:Release>>:QML_IMPORT_TRACE=1>
)

#
# Compile options
#
target_compile_options (qmldev
	PRIVATE
		# All warnings, and compile as errors
		$<$<CXX_COMPILER_ID:MSVC>:/W4 /WX>
		$<$<CXX_COMPILER_ID:Clang>:-Wall -Werror>
)


#
# Create a target to install a standalone version on Windows
#
if (WIN32)

	install (TARGETS qmldev
		RUNTIME DESTINATION .
		LIBRARY DESTINATION .
		ARCHIVE DESTINATION .
	)

	install (FILES
		Main.qml
		Error.qml
		DESTINATION .
	)

	find_program (QT_DEPLOY_TOOL
		NAMES
			windeployqt
		HINTS
			${QT_DIR}/../../bin
	)

	install (CODE "
		execute_process(
			COMMAND ${QT_DEPLOY_TOOL} --qmldir \"${CMAKE_CURRENT_SOURCE_DIR}/QmlDeploy\" \"${CMAKE_INSTALL_PREFIX}/qmldev${CMAKE_EXECUTABLE_SUFFIX}\"
				--no-compiler-runtime
				--no-opengl-sw
				--no-webkit2
				--no-system-d3d-compiler
				--no-translations
				--no-qmltooling
			WORKING_DIRECTORY ${QT_DIR}/bin
		)
	")

endif ()
