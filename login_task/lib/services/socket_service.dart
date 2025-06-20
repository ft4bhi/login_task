import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class SocketService {
  late WebSocketChannel _channel;
  final String _accessToken;
  final String _gameId;
  final Function(Map<String, dynamic>) _onGameEvent;
  final Function(dynamic) _onError;
  final Function() _onDone;

  SocketService({
    required String accessToken,
    required String gameId,
    required Function(Map<String, dynamic>) onGameEvent,
    required Function(dynamic) onError,
    required Function() onDone,
  })  : _accessToken = accessToken,
        _gameId = gameId,
        _onGameEvent = onGameEvent,
        _onError = onError,
        _onDone = onDone;

  void connect() {
    // Create WebSocket with proper headers
    final wsUrl = Uri.parse('wss://lichess.org/api/board/game/stream/$_gameId');
    final headers = {
      'Authorization': 'Bearer $_accessToken',
      'Accept': 'application/json',
    };

    // For web and mobile platforms
    _channel = IOWebSocketChannel.connect(
      wsUrl,
      headers: headers,
    );

    _channel.stream.listen(
          (data) {
        try {
          final event = jsonDecode(data);
          _onGameEvent(event);
        } catch (e) {
          _onError(e);
        }
      },
      onError: _onError,
      onDone: _onDone,
    );
  }

  void sendMove(String moveUci) {
    _channel.sink.add(jsonEncode({
      'type': 'move',
      'gameId': _gameId,
      'move': {
        'uci': moveUci,
        'san': '', // Lichess will calculate this
        'promotion': moveUci.length > 4 ? moveUci[4] : null,
      },
    }));
  }

  // void close() {
  //   if (_channel.sink != null && !_channel.sink) {
  //     _channel.sink.close();
  //   }
  // }
}