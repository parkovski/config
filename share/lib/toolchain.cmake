if(WIN32)
  string(REPLACE "\\" "/" TOOLCHAIN_HOME $ENV{USERPROFILE})
else()
  set(TOOLCHAIN_HOME $ENV{HOME})
endif()
if(IS_DIRECTORY "${TOOLCHAIN_HOME}/.local")
  set(CMAKE_PREFIX_PATH "${TOOLCHAIN_HOME}/.local;${CMAKE_PREFIX_PATH}")
  message(STATUS "Toolchain: Add prefix: ${TOOLCHAIN_HOME}/.local")
endif()
unset(TOOLCHAIN_HOME)

if(DEFINED ENV{VCPKG_ROOT})
  if(WIN32)
    string(REPLACE "\\" "/" VCPKG_ROOT $ENV{VCPKG_ROOT})
  else()
    set(VCPKG_ROOT $ENV{VCPKG_ROOT})
  endif()
  include("${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
  message(STATUS "Toolchain: Include vcpkg: ${VCPKG_ROOT}")
endif()

add_compile_options(
  $<$<OR:$<C_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:GNU>>:-fdiagnostics-color=always>
  $<$<OR:$<C_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:Clang>>:-fcolor-diagnostics>
  $<$<OR:$<C_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:AppleClang>>:-fcolor-diagnostics>
  $<$<OR:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>:/diagnostics:caret>
)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)