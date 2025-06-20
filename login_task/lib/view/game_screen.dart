import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chess/chess.dart' as chess;

class GameScreen extends StatefulWidget {
  final String accessToken;
  final String gameId;

  const GameScreen({
    required this.accessToken,
    required this.gameId,
    Key? key,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late chess.Chess _chess;
  late IOWebSocketChannel _socket;
  List<String> _moveHistory = [];
  TextEditingController _moveController = TextEditingController();
  bool _isMyTurn = false;
  String _gameStatus = 'Game started';
  String _myColor = 'white';

  @override
  void initState() {
    super.initState();
    _chess = chess.Chess();
    _connectToGame();
  }

  void _connectToGame() {
    _socket = IOWebSocketChannel.connect(
      Uri.parse('wss://lichess.org/api/board/game/stream/${widget.gameId}'),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    _socket.stream.listen(_handleGameEvent,
      onError: (error) => _updateStatus('Connection error: $error'),
      onDone: () => _updateStatus('Disconnected from game'),
    );
  }

  void _handleGameEvent(dynamic data) {
    final event = jsonDecode(data);
    switch (event['type']) {
      case 'gameFull':
        _handleGameFull(event);
        break;
      case 'gameState':
        _handleGameState(event);
        break;
    }
  }

  void _handleGameFull(Map<String, dynamic> data) {
    final initialFen = data['initialFen'] ?? 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

    // Use load method for the chess package
    try {
      _chess.load(initialFen);
    } catch (e) {
      _updateStatus('Error loading FEN: $e');
    }

    // Determine if we're playing as white or black
    final myId = _getMyLichessId();
    if (data['white'] != null && data['white']['id'] == myId) {
      _myColor = 'white';
    } else {
      _myColor = 'black';
    }

    _updateTurnStatus();
  }

  void _handleGameState(Map<String, dynamic> data) {
    final moves = data['moves']?.split(' ') ?? [];

    // Clear current position and replay all moves
    _chess.reset();
    _moveHistory.clear();

    // Process all moves from the beginning
    for (final move in moves) {
      if (move.isNotEmpty && move.length >= 4) {
        try {
          final from = move.substring(0, 2);
          final to = move.substring(2, 4);
          final promotion = move.length > 4 ? move.substring(4) : null;

          final moveObj = {
            'from': from,
            'to': to,
            if (promotion != null) 'promotion': promotion,
          };

          final moveSuccess = _chess.move(moveObj);
          if (moveSuccess) {
            // Get the SAN notation from the last move in history
            final history = _chess.getHistory();
            if (history.isNotEmpty) {
              _moveHistory.add(history.last.toString());
            }
          }
        } catch (e) {
          print('Error processing move $move: $e');
        }
      }
    }

    _updateTurnStatus();
    _updateStatus(data['status'] ?? 'Game in progress');
  }

  void _updateTurnStatus() {
    setState(() {
      _isMyTurn = _chess.turn == (_myColor == 'white' ? 'w' : 'b');
    });
  }

  void _updateStatus(String status) {
    setState(() {
      _gameStatus = status;
    });
  }

  String _getMyLichessId() {
    try {
      final parts = widget.accessToken.split('.');
      if (parts.length > 1) {
        final payload = jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
        );
        return payload['sub'] ?? '';
      }
    } catch (e) {
      print('Error parsing JWT: $e');
    }
    return '';
  }

  Future<void> _sendMove(String moveNotation) async {
    if (!_isMyTurn) {
      _updateStatus("Not your turn!");
      return;
    }

    try {
      // Store current position in case we need to undo
      final currentFen = _chess.fen;

      // Try to make the move
      final moveSuccess = _chess.move(moveNotation);

      if (!moveSuccess) {
        _updateStatus("Invalid move: $moveNotation");
        return;
      }

      // Get the last move from history
      final history = _chess.getHistory();
      if (history.isEmpty) {
        _updateStatus("Error: Could not get move details");
        _chess.load(currentFen); // Restore position
        return;
      }

      // For a simple approach, try to send the move as entered
      // Lichess API might accept SAN notation directly
      final response = await http.post(
        Uri.parse('https://lichess.org/api/bot/game/${widget.gameId}/move/$moveNotation'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _moveController.clear();
          // Don't add to history here - it will be updated via websocket
        });
      } else {
        _updateStatus("Move failed: ${response.body}");
        _chess.load(currentFen); // Restore position
      }
    } catch (e) {
      _updateStatus("Error: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    _socket.sink.close();
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game ${widget.gameId.substring(0, 8)}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_gameStatus, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Playing as: $_myColor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _moveHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${index + 1}. ${_moveHistory[index]}'),
                  );
                },
              ),
            ),
            if (_isMyTurn) ...[
              TextField(
                controller: _moveController,
                decoration: InputDecoration(
                  labelText: 'Enter your move (e.g. e4, Nf3)',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _sendMove(_moveController.text),
                  ),
                ),
                onSubmitted: _sendMove,
              ),
              SizedBox(height: 10),
              Text('Your turn!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ] else ...[
              Text('Waiting for opponent...', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }
}