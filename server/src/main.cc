#include <exception>
#include <iostream>

#include "flatbuffers/verifier.h"
#include "websocketpp/close.hpp"
#include "websocketpp/common/connection_hdl.hpp"
#include "websocketpp/config/asio_no_tls.hpp"
#include "websocketpp/error.hpp"
#include "websocketpp/logger/levels.hpp"
#include "websocketpp/roles/server_endpoint.hpp"
#include "websocketpp/server.hpp"

#include "generated/protocol_flatbuffers.h"

int main() {
  try {
    std::cout << "testing" << std::endl;

    using ServerT = websocketpp::server<websocketpp::config::asio>;
    ServerT echo_server;

    echo_server.set_access_channels(websocketpp::log::alevel::all);
    echo_server.clear_access_channels(websocketpp::log::alevel::frame_payload);

    echo_server.init_asio();

    echo_server.set_open_handler([](websocketpp::connection_hdl hdl) {
      std::cout << "Connection opened: " << hdl.lock().get() << std::endl;
    });

    echo_server.set_message_handler([&echo_server](
                                        websocketpp::connection_hdl hdl,
                                        ServerT::message_ptr message) {
      /// Validate the payload.

      auto& payload = message->get_payload();
      flatbuffers::Verifier verifier(
          (uint8_t*)payload.data(), payload.size(),
          flatbuffers::Verifier::Options{.max_tables = 10});
      if (!wstest::fb::VerifyMessageBuffer(verifier)) {
        std::cerr << "Validation failed for payload received from "
                  << hdl.lock().get() << "; closing connection." << std::endl;

        echo_server.close(hdl, websocketpp::close::status::invalid_payload,
                          "Invalid payload.");
        return;
      }

      /// Parse the payload.

      const wstest::fb::Message* fb_message =
          wstest::fb::GetMessage(message->get_payload().data());

      switch (fb_message->payload_type()) {
        case wstest::fb::AnyPayload::LoginPayload:
          // TODO(bdero): Respond with ack
          break;
        case wstest::fb::AnyPayload::LoginAckPayload:
        case wstest::fb::AnyPayload::NONE:
          std::cerr << "Received invalid payload from connection "
                    << hdl.lock().get() << "; closing connection." << std::endl;

          echo_server.close(hdl, websocketpp::close::status::invalid_payload,
                            "Invalid payload.");
      }

      std::cout << "on_message called with hdl: " << hdl.lock().get()
                << " and message: " << message->get_payload() << std::endl;

      try {
        echo_server.send(hdl, message->get_payload(), message->get_opcode());
      } catch (websocketpp::exception const& e) {
        std::cout << "Echo failed because: "
                  << "(" << e.what() << ")" << std::endl;
      }
    });

    echo_server.set_close_handler([](websocketpp::connection_hdl hdl) {
      std::cout << "Connection closed: " << hdl.lock().get() << std::endl;
    });

    echo_server.listen(9002);
    echo_server.start_accept();
    echo_server.run();
  } catch (std::exception const& e) {
    std::cerr << "Unhandled exception thrown: " << e.what() << std::endl;
    return 1;
  }
  return 0;
}
