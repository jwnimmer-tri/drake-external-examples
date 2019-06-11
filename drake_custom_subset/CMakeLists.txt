# -*- mode: cmake -*-
# vi: set ft=cmake :

# Copyright (c) 2013-2019, Massachusetts Institute of Technology.
# Copyright (c) 2016-2019, Toyota Research Institute.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

cmake_minimum_required(VERSION 3.10.2)
project(drake_custom_subset)

find_program(Bazel_EXECUTABLE bazel)

set(SUPPORTED_BUILD_TYPES None Debug Release RelWithDebInfo MinSizeRel)
if(CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_CONFIGURATION_TYPES ${SUPPORTED_BUILD_TYPES})
else()
  if(NOT CMAKE_BUILD_TYPE)
    string(REPLACE ";" " " SUPPORTED_BUILD_TYPES_STRING
      "${SUPPORTED_BUILD_TYPES}"
    )
    set(CMAKE_BUILD_TYPE Release CACHE STRING
      "Choose the type of build, options are ${SUPPORTED_BUILD_TYPES_STRING}"
      FORCE
    )
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY
      STRINGS "${SUPPORTED_BUILD_TYPES}"
    )
  endif()

  if(NOT CMAKE_BUILD_TYPE IN_LIST SUPPORTED_BUILD_TYPES)
    message(WARNING "Configuration ${CMAKE_BUILD_TYPE} is NOT supported")
  endif()
endif()

if(CMAKE_COLOR_MAKEFILE)
  set(BAZEL_COLOR yes)
else()
  set(BAZEL_COLOR no)
endif()

if(CMAKE_VERBOSE_MAKEFILE)
  set(BAZEL_SUBCOMMANDS yes)
else()
  set(BAZEL_SUBCOMMANDS no)
endif()

get_filename_component(PROJECT_BINARY_DIR_REALPATH
  "${PROJECT_BINARY_DIR}" REALPATH
)
get_filename_component(PROJECT_SOURCE_DIR_REALPATH
  "${PROJECT_SOURCE_DIR}" REALPATH
)

# Check whether the PROJECT_BINARY_DIR is a subdirectory of the
# PROJECT_SOURCE_DIR.
string(FIND "${PROJECT_BINARY_DIR_REALPATH}/" "${PROJECT_SOURCE_DIR_REALPATH}/"
  STRING_FIND_RESULT_VARIABLE
)

if(STRING_FIND_RESULT_VARIABLE EQUAL 0)
  # The --output_base cannot be within the WORKSPACE (a subdirectory of
  # PROJECT_SOURCE_DIR), so fallback to the using the same parent directory
  # that Bazel uses by default for its --output_base.
  if(APPLE)
    set(BAZEL_OUTPUT_BASE "/var/tmp")
  else()
    set(BAZEL_OUTPUT_BASE "$ENV{HOME}/.cache/bazel")
  endif()
else()
  set(BAZEL_OUTPUT_BASE "${PROJECT_BINARY_DIR}")
endif()

# Compute the MD5 hash of the PROJECT_BINARY_DIR rather than the WORKSPACE
# (PROJECT_SOURCE_DIR) to avoid colliding with the directory that Bazel uses by
# default.
string(MD5 PROJECT_BINARY_DIR_MD5 "${PROJECT_BINARY_DIR_REALPATH}")
set(BAZEL_OUTPUT_BASE
  "${BAZEL_OUTPUT_BASE}/_bazel_$ENV{USER}/${PROJECT_BINARY_DIR_MD5}"
)

if(CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE MATCHES "^(Debug|MinSizeRel|Release|RelWithDebInfo)$")
  set(BAZEL_CONFIG_ARG
    "$<$<CONFIG:Debug>:--config=Debug>$<$<CONFIG:MinSizeRel>:--config=MinSizeRel>$<$<CONFIG:Release>:--config=Release>$<$<CONFIG:RelWithDebInfo>:--config=RelWithDebInfo>"
  )
else()
  set(BAZEL_CONFIG_ARG "build --config=Release")
endif()

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${PROJECT_BINARY_DIR}/install" CACHE STRING
    "Install path prefix, prepended onto install directories" FORCE
  )
endif()

set(BAZEL_INSTALL_TARGET_ARGS "${CMAKE_INSTALL_PREFIX}")

if(CMAKE_INSTALL_NAME_TOOL)
  list(INSERT BAZEL_INSTALL_TARGET_ARGS 0
    "--install_name_tool"
    "${CMAKE_INSTALL_NAME_TOOL}"
  )
endif()

if(CMAKE_STRIP)
  list(INSERT BAZEL_INSTALL_TARGET_ARGS 0 "--strip_tool" "${CMAKE_STRIP}")
endif()

# If CMAKE_BUILD_TYPE is Debug or RelWithDebInfo, do NOT strip symbols during
# install.
if(CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE MATCHES "^(Debug|RelWithDebInfo)$")
  list(INSERT BAZEL_INSTALL_TARGET_ARGS 0 "$<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:--no_strip>")
endif()

find_package(Eigen3 3.3 REQUIRED NO_MODULE)
find_package(fmt REQUIRED)

configure_file(wrap/.bazelrc.in wrap/.bazelrc @ONLY)
configure_file(wrap/BUILD.bazel wrap/BUILD.bazel COPYONLY)
configure_file(wrap/WORKSPACE wrap/WORKSPACE COPYONLY)
configure_file(wrap/ccd.bzl wrap/ccd.bzl COPYONLY)
configure_file(wrap/drake.bzl wrap/drake.bzl COPYONLY)
configure_file(wrap/eigen.bzl.in wrap/eigen.bzl @ONLY)
configure_file(wrap/fcl.bzl wrap/fcl.bzl COPYONLY)
configure_file(wrap/fmt.bzl.in wrap/fmt.bzl @ONLY)
configure_file(wrap/octomap.bzl wrap/octomap.bzl COPYONLY)
configure_file(wrap/spdlog.bzl wrap/spdlog.bzl COPYONLY)
configure_file(wrap/spruce.bzl wrap/spruce.bzl COPYONLY)
configure_file(wrap/stx.bzl wrap/stx.bzl COPYONLY)
configure_file(wrap/tinyobjloader.bzl wrap/tinyobjloader.bzl COPYONLY)

configure_file(/dev/null wrap/empty_directory/.empty COPYONLY)

# get_cmake_property(_variableNames VARIABLES)
# list (SORT _variableNames)
# foreach (_variableName ${_variableNames})
#     message(STATUS "${_variableName}=${${_variableName}}")
# endforeach()

include(ExternalProject)

ExternalProject_Add(drake_custom_cxx
  SOURCE_DIR "${PROJECT_SOURCE_DIR}"
  CONFIGURE_COMMAND :
  BUILD_COMMAND
    "${Bazel_EXECUTABLE}"
    build
    //...
  BINARY_DIR "${PROJECT_BINARY_DIR}/wrap"
  BUILD_ALWAYS ON
  INSTALL_COMMAND
    "${Bazel_EXECUTABLE}"
    run
    //:install
    --
    ${BAZEL_INSTALL_TARGET_ARGS}
  USES_TERMINAL_BUILD ON
  USES_TERMINAL_INSTALL ON
)

list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")
