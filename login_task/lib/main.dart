import 'package:flutter/material.dart';
import 'view/login_page.dart'; // 👈 Import the login screen

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lichess App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: LoginPage(), // 👈 Use your LoginPage here
    );
  }
}
