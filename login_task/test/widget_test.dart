import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lichess_flutter_app/main.dart'; // ✅ corrected import

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp()); // ✅ removed const if MyApp is not const

    // Your test logic (optional: update for your actual UI)
    expect(find.text('Login with Lichess'), findsOneWidget);
  });
}
