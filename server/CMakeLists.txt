cmake_minimum_required(VERSION 3.21)

set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(THIRD_PARTY_DIR ${SOURCE_DIR}/third_party)
set(GENERATED_DIR ${SOURCE_DIR}/generated)

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

add_subdirectory(${THIRD_PARTY_DIR}/websocketpp)

add_executable(wstest_server ${SOURCE_DIR}/main.cc)

target_include_directories(wstest_server
    PUBLIC
        ${SOURCE_DIR}
        ${THIRD_PARTY_DIR}/websocketpp)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/asio.cmake)
target_link_libraries(wstest_server asio)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/flatbuffers.cmake)

flatbuffers_schema(
    TARGET wstest_server
    INPUT ${SOURCE_DIR}/protocol.fbs
    OUTPUT_DIR ${GENERATED_DIR})
