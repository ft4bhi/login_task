import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'game_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  final String accessToken;

  const MatchmakingScreen({required this.accessToken, Key? key}) : super(key: key);

  @override
  _MatchmakingScreenState createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  bool _isMatchmaking = false;
  String? _selectedTimeControl = '300+5'; // Default: 5+5
  String? _selectedVariant = 'standard';
  bool _rated = false;

  // Time control options
  final Map<String, String> _timeControls = {
    '180+0': 'Bullet (3+0)',
    '180+2': 'Blitz (3+2)',
    '300+0': 'Blitz (5+0)',
    '300+5': 'Rapid (5+5)',
    '600+10': 'Rapid (10+10)',
  };

  // Variant options
  final Map<String, String> _variants = {
    'standard': 'Standard',
    'chess960': 'Chess960',
    'crazyhouse': 'Crazyhouse',
    'antichess': 'Antichess',
    'atomic': 'Atomic',
    'horde': 'Horde',
    'kingOfTheHill': 'King of the Hill',
    'racingKings': 'Racing Kings',
    'threeCheck': 'Three-check',
  };

  Future<String> _startSeek() async {
    final parts = _selectedTimeControl!.split('+');
    final limit = int.parse(parts[0]);
    final increment = int.parse(parts[1]);

    final response = await http.post(
      Uri.parse('https://lichess.org/api/board/seek'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {
        'rated': _rated ? 'true' : 'false',
        'time': limit.toString(),
        'increment': increment.toString(),
        'variant': _selectedVariant,
        'color': 'random',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to start seek: ${response.body}');
    }

    // In a real app, you would connect to Lichess's event stream here
    // and wait for the gameStart event. For this example, we'll simulate it.
    await Future.delayed(Duration(seconds: 3));
    return 'simulated-game-id-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Find Opponent')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Matchmaking', style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 16),

                    // Time Control Selection
                    DropdownButtonFormField<String>(
                      value: _selectedTimeControl,
                      items: _timeControls.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedTimeControl = value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Time Control',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Variant Selection
                    DropdownButtonFormField<String>(
                      value: _selectedVariant,
                      items: _variants.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedVariant = value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Variant',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Rated Toggle
                    SwitchListTile(
                      title: Text('Rated Game'),
                      value: _rated,
                      onChanged: (value) {
                        setState(() => _rated = value);
                      },
                    ),
                    SizedBox(height: 16),

                    // Find Opponent Button
                    ElevatedButton(
                      onPressed: _isMatchmaking ? null : () async {
                        setState(() => _isMatchmaking = true);
                        try {
                          final gameId = await _startSeek();
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameScreen(
                                accessToken: widget.accessToken,
                                gameId: gameId,
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}'))
                          );
                          setState(() => _isMatchmaking = false);
                        }
                      },
                      child: _isMatchmaking
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 8),
                          Text('Finding opponent...'),
                        ],
                      )
                          : Text('Find Opponent'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Information text
            Text(
              'This will find you a random opponent from Lichess matchmaking pool. '
                  'The game will start automatically when an opponent is found.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}