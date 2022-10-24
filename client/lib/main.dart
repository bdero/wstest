import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'generated/protocol_wstest.fb_generated.dart' as protocol;
import 'package:crypto/crypto.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'WebSocket Demo';
    return const MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:9002'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    autocorrect: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username required.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password required.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                return Text(snapshot.hasData ? '${snapshot.data}' : '');
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final passwordBytes = utf8.encode(_passwordController.text);
    final passwordDigest = sha512.convert(passwordBytes);

    final builder = fb.Builder();

    final loginPayload = protocol.LoginPayloadBuilder(builder)
      ..begin()
      ..addUsernameOffset(builder.writeString(_usernameController.text))
      ..addPasswordOffset(builder.writeString(passwordDigest.toString()));

    final messageBuilder = protocol.MessageBuilder(builder)
      ..begin()
      ..addPayloadType(protocol.AnyPayloadTypeId.LoginPayload)
      ..addPayloadOffset(loginPayload.finish());

    messageBuilder.finish();
    builder.finish(messageBuilder.finish());

    if (_usernameController.text.isNotEmpty) {
      _channel.sink.add(builder.buffer);
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _usernameController.dispose();
    super.dispose();
  }
}
