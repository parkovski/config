if(WIN32)
  string(REPLACE "\\" "/" HOME $ENV{USERPROFILE})
else()
  set(HOME $ENV{HOME})
endif()

set(CMAKE_PREFIX_PATH "${HOME}/local;${CMAKE_PREFIX_PATH}")

if(DEFINED ENV{VCPKG_ROOT})
  if(WIN32)
    string(REPLACE "\\" "/" VCPKG_ROOT $ENV{VCPKG_ROOT})
  else()
    set(VCPKG_ROOT $ENV{VCPKG_ROOT})
  endif()
  include("${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # /utf-8 ??
  add_compile_options(/diagnostics:caret)
endif()

# Clang:
# add_compile_options(-fcolor-diagnostics)
# string(FIND ${CMAKE_PREFIX_PATH} libc++ find_libcxx)
# if(NOT find_libcxx EQUAL -1)
#   message(STATUS "Using libc++")
#   set(CMAKE_INSTALL_PREFIX "${HOME}/local/lib.libc++")
# endif()

# GCC:
# add_compile_options(-fdiagnostics-color=always)