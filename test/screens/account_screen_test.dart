import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinity_app/screens/account_screen.dart';
import 'package:trinity_app/api/token_service.dart';

void main() {
  group('AccountScreen UI', () {
    testWidgets(
        'Affiche le loader quand les données sont en cours de chargement',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AccountScreen()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Affiche le titre "Mon Profil"', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AccountScreen()));
      await tester.pumpAndSettle(); // attendre le chargement

      expect(find.textContaining("Mon Profil"), findsOneWidget);
    });

    testWidgets('Affiche tous les champs du formulaire',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AccountScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Prénom"), findsOneWidget);
      expect(find.text("Nom"), findsOneWidget);
      expect(find.text("Email"), findsOneWidget);
      expect(find.text("Téléphone"), findsOneWidget);
      expect(find.text("Adresse"), findsOneWidget);
      expect(find.text("Code Postal"), findsOneWidget);
      expect(find.text("Ville"), findsOneWidget);
      expect(find.text("Pays"), findsOneWidget);
    });

    testWidgets('Affiche le bouton Modifier et Déconnecter',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AccountScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Se déconnecter"), findsOneWidget);
      expect(find.text("Modifier"), findsOneWidget);
    });
  });

  // Tests de logique métier (mock à faire avec Mockito ou Fake)
  group('AccountScreen Logic', () {
    test('getUserIdFromToken retourne null si token invalide', () async {
      final userId = await TokenService.getUserIdFromToken();
      expect(userId, isNull);
    });

    // Pour tester _fetchUserData, _updateUserData => mock de ApiService nécessaire
  });
}
