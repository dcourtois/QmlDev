#
# This contains all boring setup stuff needed by the main CMake file.
#

#
# Configure Qt.
#
# This is configured for my various computers installation so that I don't have to bother, but you can
# customize that to your needs during configure:
#
# -DQT_ROOT=<path> : make this point to the lib/cmake folder of your Qt installation.
#
set (QT_SUBDIR "Libs/Qt/5.13.2")
set (QT_ROOT ${QT_ROOT} "C:/Development/${QT_SUBDIR}" "D:/Development/${QT_SUBDIR}" "~/Development/${QT_SUBDIR}")
set (QT_SUFFIX ${QT_SUFFIX} "msvc2017_64/lib/cmake" "gcc_64/lib/cmake" "clang_64/lib/cmake")
set (QT_COMPONENTS Qml Quick QuickControls2 Svg)
set (QT_VERSION 5)

#
# automatically handle moc and rcc
#
set (CMAKE_AUTOMOC ON)
set (CMAKE_AUTORCC ON)

# windows specific configurations
if (WIN32)

	# from each config var, remove:
	# - warnings : we'll set those for each target
	# - runtime : we'll use /MD for all configs
	foreach (CONF IN ITEMS "" "_RELEASE" "_DEBUG" "_RELWITHDEBINFO" "_MINSIZEREL")
		string (REGEX REPLACE "[/\\-]W[1-4]" "" CMAKE_CXX_FLAGS${CONF} "${CMAKE_CXX_FLAGS${CONF}}")
		string (REGEX REPLACE "[/\\-]M[TD]d?" "" CMAKE_CXX_FLAGS${CONF} "${CMAKE_CXX_FLAGS${CONF}}")
	endforeach ()

	# force release runtime
	# note that we can't just use the MSVC_RUNTIME property, it's ignored by precompiled headers
	set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MD")

endif ()
