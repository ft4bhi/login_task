import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String username;
  final int blitzRating;

  const HomePage({required this.username, required this.blitzRating, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello, $username!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 12),
            Text('Blitz Rating: $blitzRating'),
          ],
        ),
      ),
    );
  }
}
