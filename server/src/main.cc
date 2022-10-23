#include <exception>
#include <iostream>

#include "websocketpp/common/connection_hdl.hpp"
#include "websocketpp/config/asio_no_tls.hpp"
#include "websocketpp/error.hpp"
#include "websocketpp/logger/levels.hpp"
#include "websocketpp/roles/server_endpoint.hpp"
#include "websocketpp/server.hpp"

int main() {
  try {
    std::cout << "testing" << std::endl;

    using ServerT = websocketpp::server<websocketpp::config::asio>;
    ServerT echo_server;

    echo_server.set_access_channels(websocketpp::log::alevel::all);
    echo_server.clear_access_channels(websocketpp::log::alevel::frame_payload);

    echo_server.init_asio();

    echo_server.set_message_handler([&echo_server](
                                        websocketpp::connection_hdl hdl,
                                        ServerT::message_ptr message) {
      std::cout << "on_message called with hdl: " << hdl.lock().get()
                << " and message: " << message->get_payload() << std::endl;

      try {
        echo_server.send(hdl, message->get_payload(), message->get_opcode());
      } catch (websocketpp::exception const& e) {
        std::cout << "Echo failed because: "
                  << "(" << e.what() << ")" << std::endl;
      }
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
