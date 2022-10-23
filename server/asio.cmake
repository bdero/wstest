add_library(asio
    ${CMAKE_CURRENT_SOURCE_DIR}/src/third_party/asio/asio/src/asio.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/third_party/asio/asio/src/asio_ssl.cpp)

target_include_directories(asio
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src/third_party/asio/asio/include)

target_compile_definitions(asio
    PUBLIC
        ASIO_STANDALONE
        ASIO_SEPARATE_COMPILATION)

# OpenSSL::SSL OpenSSL::Crypto

target_include_directories(asio PUBLIC ${OPENSSL_INCLUDE_DIR})
target_link_libraries(asio PUBLIC ${OPENSSL_LIBRARIES})
