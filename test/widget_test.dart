import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:trinity_app/main.dart'; 
import 'package:trinity_app/screens/login_screen.dart';

void main() {
  testWidgets('L\'application démarre sur la route de login', (WidgetTester tester) async {
    // Instanciation de MyApp en passant explicitement initialRoute "/login"
    await tester.pumpWidget(const MyApp(initialRoute: "/login"));
    await tester.pumpAndSettle();

    // Vérifie qu'un widget de LoginScreen est présent
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
