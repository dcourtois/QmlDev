#
# Collection of utility functions for CMake that I often use throughout
# my various projects.
#

# totally remove warnings. This lets us set the warning level we want per target
# without command lines complaining when we override the warning levels.
string (REGEX REPLACE "(/W[^ ]+)|(-W[123])" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

# disable banner of the resource compiler on Windows
set (CMAKE_RC_FLAGS "/nologo")

#
# Custom option with a default value. This is meant to be used in the root
# CMake script file to expose some variables for overriding through the
# command line, while providing a fallback value.
#
# The options defined through this function are not cached.
#
# VAR_NAME
#	Name of the variable that will store the option's value.
#
# DEFAULT_VALUE
#	The default value for the option if the user didn't specify
#	an explicit value through a -D argument.
#
function (cu_option VAR_NAME DEFAULT_VALUE)
	if (NOT DEFINED ${VAR_NAME})
		# do not set in parent scope, or the log will not work
		set (${VAR_NAME} ${DEFAULT_VALUE})
	endif ()

	# log the value (usefull for debugging)
	message (STATUS "Using ${VAR_NAME} = ${${VAR_NAME}}")

	# now make it known to the parent
	set (${VAR_NAME} ${${VAR_NAME}} PARENT_SCOPE)
endfunction ()

#
# This function can be called to configure precompiled header on the given
# target. It must be called after the files have been added to the target.
#
# It uses PCH Visual Studio like. This means that the way to use it is to
# have one header which includes all headers that you want to precompile,
# and a compilation unit which includes it, and creates the PCH file.
#
# PCH_TARGET_NAME
#	The name of the target lib/app/whatever we want to modify
#
# PCH_HEADER
#	The name of the header file. This must be the same string that appears
#	at the top of each compilation unit using PCH.
#
# PCH_SOURCE
#	The name of the source file that will generate the precompiled header.
#
# Example use:
# ```
# add_library (Foo Sources/A.cpp Sources/B.cpp Sources/PCH.cpp Sources/PCH.h)
# target_pch (Foo Sources/PCH.h Sources/PCH.cpp)
#
# # note that on MSVC, A.cpp and B.cpp must start by #include "Sources/PCH.h" !
# ```
#
function (target_pch PCH_TARGET_NAME PCH_HEADER PCH_SOURCE)

	# note: clang-cl is a special Clang driver which accepts MSVC arguments, so we want
	# to detect this case to set things up correctly
	string (FIND ${CMAKE_CXX_COMPILER} "clang-cl" COMPILER)

	# MSVC
	if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR NOT COMPILER EQUAL -1)

		message (STATUS "Setuping precompiled headers for MSVC...")

		# get the files of the target
		get_target_property (TARGET_SOURCES ${PCH_TARGET_NAME} SOURCES)

		# iterate to setup the PCH related flags
		foreach (SOURCE ${TARGET_SOURCES})

			if (${SOURCE} STREQUAL ${PCH_SOURCE})

				# this is the PCH source which generates the PCH file
				set_source_files_properties (${SOURCE} PROPERTIES COMPILE_FLAGS "/Fp${PCH_HEADER}.pch /Yc${PCH_HEADER}")
				set_source_files_properties (${SOURCE} PROPERTIES OBJECT_OUTPUTS "${PCH_HEADER}.pch")

			else ()

				# this is not, set it to use the generated PCH file
				set_source_files_properties (${SOURCE} PROPERTIES OBJECT_DEPENDS "${PCH_HEADER}.pch")
				set_source_files_properties (${SOURCE} PROPERTIES COMPILE_FLAGS "/Fp${PCH_HEADER}.pch /Yu${PCH_HEADER}")

			endif ()

		endforeach ()

	else ()

		message (WARNING "target_pch - ${CMAKE_CXX_COMPILER_ID} compiler not supported. PCH will not be used on ${PCH_TARGET_NAME}")

		# set the NO_PCH define to avoid slowing down compilation
		target_compile_definitions (${PCH_TARGET_NAME} PUBLIC NO_PCH)

	endif ()

endfunction ()
