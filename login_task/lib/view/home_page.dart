import 'package:flutter/material.dart';
import 'player_search.dart'; // Adjust the path as needed

class HomePage extends StatelessWidget {
  final String accessToken;
  final String opponentUsername;

  const HomePage({
    required this.accessToken,
    required this.opponentUsername,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lichess Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchmakingScreen(
                      accessToken: accessToken,
                    ),
                  ),
                );
              },
              child: Text('Play vs Player'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement computer game
              },
              child: Text('Play vs Computer'),
            ),
          ],
        ),
      ),
    );
  }
}