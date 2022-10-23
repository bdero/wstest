cmake_minimum_required(VERSION 3.21)

### vcpkg

if(WIN32)
    set(VCPKG_TARGET_TRIPLET "x64-windows-static")
endif()

set(CMAKE_TOOLCHAIN_FILE
    "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake"
    CACHE STRING "Vcpkg toolchain file")

project(wstest_server LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(MSVC $<CXX_COMPILER_ID:MSVC>)
set(NOT_MSVC $<NOT:$<CXX_COMPILER_ID:MSVC>>)

#add_compile_options(
#    $<${NOT_MSVC}:-fexceptions>
#)

find_package(OpenSSL REQUIRED)

add_subdirectory(src/third_party/websocketpp)

add_executable(wstest_server src/main.cc)

target_include_directories(wstest_server
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/third_party/websocketpp)

include(asio.cmake)
target_link_libraries(wstest_server asio)
