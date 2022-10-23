add_library(asio
    ${THIRD_PARTY_DIR}/asio/asio/src/asio.cpp
    ${THIRD_PARTY_DIR}/asio/asio/src/asio_ssl.cpp)

target_include_directories(asio
    PUBLIC
    ${THIRD_PARTY_DIR}/asio/asio/include)

target_compile_definitions(asio
    PUBLIC
        ASIO_STANDALONE
        ASIO_SEPARATE_COMPILATION)

# OpenSSL::SSL OpenSSL::Crypto

target_include_directories(asio PUBLIC ${OPENSSL_INCLUDE_DIR})
target_link_libraries(asio PUBLIC ${OPENSSL_LIBRARIES})
