import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

import 'home_page.dart'; // Make sure this file exists

const LICHESS_CLIENT_ID = 'lichess.org'; // Public client
const REDIRECT_URI = 'com.example.lichessapp://oauthredirect';
const LICHESS_API = 'https://lichess.org/api';

final FlutterAppAuth appAuth = FlutterAppAuth();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> loginWithLichess() async {
    try {
      final request = AuthorizationTokenRequest(
        LICHESS_CLIENT_ID,
        REDIRECT_URI,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: 'https://lichess.org/oauth',
          tokenEndpoint: 'https://lichess.org/api/token',
        ),
        scopes: ['preference:read', 'challenge:write', 'board:play'],
      );

      final result = await appAuth.authorizeAndExchangeCode(request);

      if (result != null) {
        final userInfo = await fetchUserInfo(result.accessToken!);
        final username = userInfo['username'];
        final blitzRating = userInfo['perfs']?['blitz']?['rating'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              accessToken: result.accessToken!,
              opponentUsername: "someOpponentUsername", // You can make this dynamic later
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Login error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserInfo(String token) async {
    final response = await http.get(
      Uri.parse('$LICHESS_API/account'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('❌ Failed to fetch user info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login with Lichess')),
      body: Center(
        child: ElevatedButton(
          onPressed: loginWithLichess,
          child: Text('Login with Lichess'),
        ),
      ),
    );
  }
}
