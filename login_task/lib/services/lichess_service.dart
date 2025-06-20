import 'package:http/http.dart' as http;
import 'dart:convert';

class LichessService {
  final String accessToken;

  LichessService(this.accessToken);

  Future<List<dynamic>> searchPlayers(String query) async {
    final response = await http.get(
      Uri.parse('https://lichess.org/api/player/autocomplete?term=$query'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createChallenge(String opponent) async {
    final response = await http.post(
      Uri.parse('https://lichess.org/api/challenge/$opponent'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'rated': false,
        'clock.limit': 300,
        'clock.increment': 5,
        'color': 'random',
      }),
    );
    return json.decode(response.body);
  }
}